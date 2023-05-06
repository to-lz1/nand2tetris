# frozen_string_literal: true

class CodeWriter
  def initialize(output_name)
    init_stream(output_name)
    @label_index = 0
  end

  def set_file_name(file_name)
    @file_name = file_name
  end

  def write_init
    @file.write("@256\n")
    @file.write("D=A\n")
    @file.write("@SP\n")
    @file.write("M=D\n")
    write_call("Sys.init", 0)
  end

  def write_arithmetic(command)
    case command
    when 'add'
      write_binary_operation('M+D')
    when 'sub'
      write_binary_operation('M-D')
    when 'and'
      write_binary_operation('M&D')
    when 'or'
      write_binary_operation('M|D')
    when 'eq'
      write_bool_operation('JEQ')
    when 'lt'
      write_bool_operation('JLT')
    when 'gt'
      write_bool_operation('JGT')
    when 'neg'
      write_unary_operation('-M')
    when 'not'
      write_unary_operation('!M')
    else
      raise ArgumentError, "invalid command. command: #{command}"
    end
  end

  def write_push_pop(command, segment, index)
    case command
    when 'C_PUSH'
      write_push_procedure_by_segment(segment, index)
    when 'C_POP'
      write_pop_procedure_by_segment(segment, index)
    else
      raise ArgumentError, "invalid command. command: #{command}"
    end
  end

  def write_label(label)
    @file.write("(#{get_label(label)})\n")
  end

  def write_goto(label)
    @file.write("@#{get_label(label)}\n")
    @file.write("0;JMP\n")
  end

  def write_if(label)
    write_pop_from_stack
    @file.write("D=M\n")
    @file.write("@#{get_label(label)}\n")
    @file.write("D;JNE\n")
  end

  def write_call(func_name, args_size)
    return_label = get_internal_label('return')
    @file.write("@#{return_label}\n")
    @file.write("D=A\n")
    write_push_into_stack
    @file.write("@#{REGISTERS[:local]}\n")
    @file.write("D=M\n")
    write_push_into_stack
    @file.write("@#{REGISTERS[:argument]}\n")
    @file.write("D=M\n")
    write_push_into_stack
    @file.write("@#{REGISTERS[:this]}\n")
    @file.write("D=M\n")
    write_push_into_stack
    @file.write("@#{REGISTERS[:that]}\n")
    @file.write("D=M\n")
    write_push_into_stack

    @file.write("@SP\n")
    @file.write("D=M\n")
    @file.write("@#{5 + args_size.to_i}\n")
    @file.write("D=D-A\n")
    @file.write("@#{REGISTERS[:argument]}\n")
    @file.write("M=D\n")

    @file.write("@SP\n")
    @file.write("D=M\n")
    @file.write("@#{REGISTERS[:local]}\n")
    @file.write("M=D\n")

    @file.write("@#{func_name}\n")
    @file.write("0;JMP\n")
    @file.write("(#{return_label})\n")
  end

  def write_function(func_name, locals_size)
    @current_func_name = func_name
    @file.write("(#{@current_func_name})\n")

    @file.write("D=0\n")
    locals_size.to_i.times do |_i|
      write_push_into_stack
    end
  end

  def write_return

    # define R9 as FRAME, and set LCL value to FRAME
    @file.write("@#{REGISTERS[:local]}\n")
    @file.write("D=M\n")
    @file.write("@R9\n")
    @file.write("M=D\n")

    # get return address(= LCL - 5), and set it to TEMP variable
    @file.write("@5\n")
    @file.write("D=D-A\n")
    @file.write("A=D\n")
    @file.write("D=M\n")
    @file.write("@R10\n")
    @file.write("M=D\n")

    # pop return value of the function, write its value to ARG address
    # ('cause its te next position from existing function frames)
    write_pop_from_stack
    @file.write("D=M\n")
    @file.write("@#{REGISTERS[:argument]}\n")
    @file.write("A=M\n")
    @file.write("M=D\n")

    # set SP to ARG + 1
    @file.write("D=A+1\n")
    @file.write("@SP\n")
    @file.write("M=D\n")

    @file.write("@R9\n")
    @file.write("D=M-1\n")
    @file.write("@R11\n")
    @file.write("M=D\n")
    @file.write("A=D\n")
    @file.write("D=M\n")
    @file.write("@#{REGISTERS[:that]}\n")
    @file.write("M=D\n")
    @file.write("@R11\n")
    @file.write("D=M-1\n")
    @file.write("@R11\n")
    @file.write("M=D\n")
    @file.write("A=D\n")
    @file.write("D=M\n")
    @file.write("@#{REGISTERS[:this]}\n")
    @file.write("M=D\n")
    @file.write("@R11\n")
    @file.write("D=M-1\n")
    @file.write("@R11\n")
    @file.write("M=D\n")
    @file.write("A=D\n")
    @file.write("D=M\n")
    @file.write("@#{REGISTERS[:argument]}\n")
    @file.write("M=D\n")
    @file.write("@R11\n")
    @file.write("D=M-1\n")
    @file.write("@R11\n")
    @file.write("M=D\n")
    @file.write("A=D\n")
    @file.write("D=M\n")
    @file.write("@#{REGISTERS[:local]}\n")
    @file.write("M=D\n")

    # go to return address
    @file.write("@R10\n")
    @file.write("A=M\n")
    @file.write("0;JMP\n")
  end

  def close
    @file.close unless @file.closed?
  end

  private

  # p.156のmemory segment mappingを参照
  REGISTERS = {
    local: 'LCL',
    argument: 'ARG',
    this: 'THIS',
    that: 'THAT',
    pointer: '3',
    temp: '5'
  }.freeze

  def init_stream(file_name)
    @file = File.open(file_name, 'w')
  end

  def write_push_procedure_by_segment(segment, index)
    case segment
    when 'constant'
      @file.write("@#{index}\n")
      @file.write("D=A\n")
    when 'local', 'argument', 'this', 'that', 'temp', 'pointer'
      @file.write("@#{REGISTERS[segment.to_sym]}\n")
      @file.write("A=M\n") if %w[local argument this that].include?(segment)
      index.times do |_i|
        @file.write("A=A+1\n")
      end
      @file.write("D=M\n")
    when 'static'
      @file.write("@#{@file_name}.#{index}\n")
      @file.write("D=M\n")
    end
    write_push_into_stack
  end

  def write_pop_procedure_by_segment(segment, index)
    write_pop_from_stack
    @file.write("D=M\n")
    case segment
    when 'local', 'argument', 'this', 'that', 'temp', 'pointer'
      @file.write("@#{REGISTERS[segment.to_sym]}\n")
      @file.write("A=M\n") if %w[local argument this that].include?(segment)
      index.times do |_i|
        @file.write("A=A+1\n")
      end
    when 'static'
      @file.write("@#{@file_name}.#{index}\n")
    end
    @file.write("M=D\n")
  end

  # pop from stack and set popped value address into A register,
  # which means that we can take its value from M
  def write_pop_from_stack
    @file.write("@SP\n")
    @file.write("M=M-1\n")
    @file.write("A=M\n")
  end

  # push D register value into stack
  def write_push_into_stack
    @file.write("@SP\n")
    @file.write("A=M\n")
    @file.write("M=D\n")

    @file.write("@SP\n")
    @file.write("M=M+1\n")
  end

  def write_binary_operation(push_target)
    write_pop_from_stack
    @file.write("D=M\n")
    write_pop_from_stack
    @file.write("D=#{push_target}\n")
    write_push_into_stack
  end

  def write_unary_operation(push_target)
    write_pop_from_stack
    @file.write("D=#{push_target}\n")
    write_push_into_stack
  end

  def write_bool_operation(mnemonic)
    write_pop_from_stack
    @file.write("D=M\n")
    write_pop_from_stack
    @file.write("D=M-D\n")

    push_true_label = get_internal_label('PUSH_TRUE')
    comp_end_label = get_internal_label('COMP_END')

    @file.write("@#{push_true_label}\n")
    @file.write("D;#{mnemonic}\n")

    # not jumped, which means we should push 'false'
    @file.write("D=0\n")
    @file.write("@#{comp_end_label}\n")
    @file.write("D;JMP\n")

    @file.write("(#{push_true_label})\n")
    @file.write("D=-1\n")
    @file.write("(#{comp_end_label})\n")
    write_push_into_stack
  end

  # use this when label name is passed from VM code.
  def get_label(label)
    prefix = @current_func_name ? "#{@current_func_name}$" : ''
    "#{prefix}#{label}"
  end

  # use this when internal program flow needs label name.
  def get_internal_label(prefix)
    label = "#{prefix}_#{@label_index}"
    @label_index += 1
    label
  end
end
