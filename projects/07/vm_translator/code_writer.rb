# frozen_string_literal: true

class CodeWriter
  def set_file_name(file_name)
    init_stream(file_name)
    @basename = File.basename(file_name, '.asm')
    @label_index = 0
  end

  def write_init
    @file.write("@SP\n")
    @file.write("M=256\n")
    @file.write("@Sys.init\n")
    @file.write("0;JMP\n")
    @file.write("(@Sys.init)\n")
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
    end
  end

  def write_label(label)
    @file.write("(#{label})\n")
  end

  def write_goto(label)
    @file.write("@#{label}")
    @file.write("0;JMP")
  end

  def write_if(label)
    write_pop_from_stack
    @file.write("@#{label}")
    @file.write("D;JMP")
  end

  def write_call(func_name, args_size)
    return_label = get_label('return')
    @file.write("@#{return_label}\n")
    @file.write("D=A\n")
    write_push_into_stack
    @file.write("@#{RESERVED_KEYWORDS_TO_REGISTERS[:local]}")
    @file.write("D=M\n")
    write_push_into_stack
    @file.write("@#{RESERVED_KEYWORDS_TO_REGISTERS[:argument]}")
    @file.write("D=M\n")
    write_push_into_stack
    @file.write("@#{RESERVED_KEYWORDS_TO_REGISTERS[:this]}")
    @file.write("D=M\n")
    write_push_into_stack
    @file.write("@#{RESERVED_KEYWORDS_TO_REGISTERS[:that]}")
    @file.write("D=M\n")
    write_push_into_stack

    @file.write("@SP\n")
    @file.write("D=M\n")
    @file.write("@#{5 + args_size}\n")
    @file.write("D=D-A\n")

    @file.write("@#{RESERVED_KEYWORDS_TO_REGISTERS[:argument]}\n")
    @file.write("M=D\n")

    @file.write("@SP\n")
    @file.write("D=M\n")
    @file.write("@#{RESERVED_KEYWORDS_TO_REGISTERS[:local]}\n")
    @file.write("M=D\n")

    @file.write("@#{func_name}")
    @file.write("0;JMP")
    @file.write("(#{return_label})")
  end

  def write_function(func_name, locals_size)
    @file.write("D=0")
    locals_size.times do |_i|
      write_push_into_stack
    end
  end

  def write_return
    @file.write("@#{RESERVED_KEYWORDS_TO_REGISTERS[:local]}\n")
    @file.write("D=M\n")
    @file.write("@R9\n")
    @file.write("M=D\n")
    @file.write("@5\n")
    # return address = LCL - 5
    @file.write("D=D-A\n")
    @file.write("@R10\n")
    @file.write("M=D\n")

    write_pop_from_stack
    @file.write("D=D+1\n")
    @file.write("@SP\n")
    @file.write("M=D\n")

    @file.write("@R9\n")
    @file.write("D=M-1\n")
    @file.write("@#{RESERVED_KEYWORDS_TO_REGISTERS[:that]}\n")
    @file.write("M=D\n")
    @file.write("D=D-1\n")
    @file.write("@#{RESERVED_KEYWORDS_TO_REGISTERS[:this]}\n")
    @file.write("M=D\n")
    @file.write("D=D-1\n")
    @file.write("@#{RESERVED_KEYWORDS_TO_REGISTERS[:argument]}\n")
    @file.write("M=D\n")
    @file.write("D=D-1\n")
    @file.write("@#{RESERVED_KEYWORDS_TO_REGISTERS[:local]}\n")
    @file.write("M=D\n")

    @file.write("@R10\n")
    @file.write("0;JMP\n")
  end

  def close
    @file.close unless @file.closed?
  end

  private

  # p.156のmemory segment mappingを参照
  RESERVED_KEYWORDS_TO_REGISTERS = {
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
      @file.write("@#{RESERVED_KEYWORDS_TO_REGISTERS[segment.to_sym]}\n")
      @file.write("A=M\n") if %w[local argument this that].include?(segment)
      index.times do |_i|
        @file.write("A=A+1\n")
      end
      @file.write("D=M\n")
    when 'static'
      @file.write("@#{@basename}.#{index}\n")
      @file.write("D=M\n")
    end
    write_push_into_stack
  end

  def write_pop_procedure_by_segment(segment, index)
    write_pop_from_stack
    @file.write("D=M\n")
    case segment
    when 'local', 'argument', 'this', 'that', 'temp', 'pointer'
      @file.write("@#{RESERVED_KEYWORDS_TO_REGISTERS[segment.to_sym]}\n")
      @file.write("A=M\n") if %w[local argument this that].include?(segment)
      index.times do |_i|
        @file.write("A=A+1\n")
      end
    when 'static'
      @file.write("@#{@basename}.#{index}\n")
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

    push_true_label = get_label('PUSH_TRUE')
    comp_end_label = get_label('COMP_END')

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

  def get_label(prefix)
    label = "#{prefix}_#{@label_index}"
    @label_index += 1
    label
  end
end
