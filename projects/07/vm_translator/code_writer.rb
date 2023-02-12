class SymbolTable
  def initialize
  end

  def set_file_name(file_name)
    raise NotImplementedError
  end

  def write_arithmetic(command)
    raise NotImplementedError
  end

  def write_push_pop(command, segment, index)
    raise NotImplementedError
  end
end
