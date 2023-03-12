class Parser
  attr_accessor :command_type, :arg1, :arg2

  def initialize(file_path)
    @src = File.open(file_path)
    advance_internal
  end

  def has_more_commands?
    !@src.closed?
  end

  def advance
    current_value = @current_line.gsub(/\/\/.*$/, '').strip
    tokens = current_value.split(' ')

    if ['push', 'pop'].include?(tokens[0])
      @command_type = "C_#{tokens[0].upcase}"
      @arg1 = tokens[1]
      @arg2 = tokens[2]&.to_i
      advance_internal
      return
    end

    if current_value.match?(/^(add|sub|neg|eq|gt|lt|and|or|not)/)
      @command_type = 'C_ARITHMETIC'
      @arg1 = tokens[0]
      @arg2 = nil
      advance_internal
      return
    end

    fail "Complie Error. invalid string '#{line}' at line #{@src.lineno}"
  end

  private

  def advance_internal
    @current_line = read_with_normalize
    while !@src.closed? && (@current_line.empty? || @current_line.match(/^\/\//))
      @current_line = read_with_normalize
    end
  end

  def read_with_normalize
    return @src.readline.gsub(/\r|\n/, '')
  rescue EOFError
    @src.close
  end
end
