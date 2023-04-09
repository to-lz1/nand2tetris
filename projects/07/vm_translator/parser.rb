# frozen_string_literal: true

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
    current_value = @current_line.gsub(%r{//.*$}, '').strip
    tokens = current_value.split(' ')

    if %w[push pop].include?(tokens[0])
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

    if current_value.match?(/^label/)
      @command_type = "C_LABEL"
      @arg1 = tokens[1]
      @arg2 = nil
      advance_internal
      return
    end

    if current_value.match?(/^goto/)
      @command_type = "C_GOTO"
      @arg1 = tokens[1]
      @arg2 = nil
      advance_internal
      return
    end

    if current_value.match?(/^function/)
      @command_type = "C_FUNCTION"
      @arg1 = tokens[1]
      @arg2 = tokens[2]
      advance_internal
      return
    end

    if current_value.match?(/^if\-goto/)
      @command_type = "C_IF"
      @arg1 = tokens[1]
      @arg2 = nil
      advance_internal
      return
    end

    if current_value.match?(/^return/)
      @command_type = "C_RETURN"
      @arg1, @arg2 = nil
      advance_internal
      return
    end

    if current_value.match?(/^call/)
      @command_type = "C_CALL"
      @arg1 = tokens[1]
      @arg2 = tokens[2]
      advance_internal
      return
    end

    raise "Complie Error. invalid string '#{line}' at line #{@src.lineno}"
  end

  private

  def advance_internal
    @current_line = read_with_normalize
    @current_line = read_with_normalize while !@src.closed? && (@current_line.empty? || @current_line.match(%r{^//}))
  end

  def read_with_normalize
    @src.readline.gsub(/\r|\n/, '')
  rescue EOFError
    @src.close
  end
end
