class CodeWriter
  def set_file_name(file_name)
    init_stream(file_name)
    @label_index = 0
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
      raise ArgumentError.new("invalid command. command: #{command}")
    end
  end

  def write_push_pop(command, segment, index)
    # todo: constantしか考えてない
    case command
    when 'C_PUSH'
      @file.write("@" +  index.to_s + "\n")
      @file.write("D=A" + "\n")

      @file.write("@SP" + "\n")
      @file.write("A=M" + "\n")
      @file.write("M=D" + "\n")

      @file.write("@SP" + "\n")
      @file.write("M=M+1" + "\n")
    when 'C_POP'
      @file.write("@SP" + "\n")
      @file.write("A=M" + "\n")
      @file.write("D=M" + "\n")

      @file.write("@" + index.to_s + "\n")
      @file.write("M=D" + "\n")

      @file.write("@SP" + "\n")
      @file.write("M=M-1" + "\n")
    end
  end

  def close
    @file.close unless @file.closed?
  end

  private

  def init_stream(file_name)
    @file = File.open(file_name, "w")
  end

  # pop from stack and set popped value address into A register,
  # which means that we can take its value from M
  def write_pop_from_stack
    @file.write("@SP" + "\n")
    @file.write("M=M-1" + "\n")

    @file.write("@SP" + "\n")
    @file.write("A=M" + "\n")
  end

  # push D register value into stuck
  def write_push_into_stack
    @file.write("@SP" + "\n")
    @file.write("A=M" + "\n")
    @file.write("M=D" + "\n")

    @file.write("@SP" + "\n")
    @file.write("M=M+1" + "\n")
  end

  def write_binary_operation(push_target)
    write_pop_from_stack
    @file.write("D=M" + "\n")
    write_pop_from_stack
    @file.write("D=#{push_target}" + "\n")
    write_push_into_stack
  end

  def write_unary_operation(push_target)
    write_pop_from_stack
    @file.write("D=#{push_target}" + "\n")
    write_push_into_stack
  end

  def write_bool_operation(mnemonic)
    write_pop_from_stack
    @file.write("D=M" + "\n")
    write_pop_from_stack
    @file.write("D=M-D" + "\n")

    push_true_label = get_label('PUSH_TRUE')
    comp_end_label = get_label('COMP_END')

    @file.write("@#{push_true_label}" + "\n")
    @file.write("D;#{mnemonic}" + "\n")

    # not jumped, which means we should push 'false'
    @file.write("D=0" + "\n")
    @file.write("@#{comp_end_label}" + "\n")
    @file.write("D;JMP" + "\n")

    @file.write("(#{push_true_label})" + "\n")
    @file.write("D=-1" + "\n")
    @file.write("(#{comp_end_label})" + "\n")
    write_push_into_stack
  end

  def get_label(prefix)
    label = "#{prefix}_#{@label_index}"
    @label_index =  @label_index + 1
    label
  end
end
