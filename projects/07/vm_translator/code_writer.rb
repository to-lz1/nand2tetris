class CodeWriter
  def set_file_name(file_name)
    init_stream(file_name)
  end

  def write_arithmetic(command)
    case command
    when 'add'
      # POP
      @file.write("@SP" + "\n")
      @file.write("M=M-1" + "\n")

      @file.write("@SP" + "\n")
      @file.write("A=M" + "\n")
      @file.write("D=M" + "\n")

      # POP + operate
      @file.write("@SP" + "\n")
      @file.write("M=M-1" + "\n")

      @file.write("@SP" + "\n")
      @file.write("A=M" + "\n")
      @file.write("D=D+M" + "\n")

      # PUSH result
      @file.write("@SP" + "\n")
      @file.write("A=M" + "\n")
      @file.write("M=D" + "\n")

      @file.write("@SP" + "\n")
      @file.write("M=M+1" + "\n")
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
end
