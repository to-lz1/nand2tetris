class Parser
  attr_accessor :current_command

  def initialize(file_path)
    @src = File.open(file_path)
    advance_internal
  end

  def has_more_commands?
    !@src.closed?
  end

  def advance
    a_match = @current_line.match(/^@(\d+)$/)
    if a_match
      @current_command = ACommand.new(a_match[1])
      advance_internal
      return
    end

    c_match = @current_line.match(/((.+)=)?([^;]+)(;(.+))?/)
    if c_match
      @current_command = CCommand.new(c_match[2], c_match[3], c_match[5])
      advance_internal
      return
    end

    fail "Complie Error. invalid string '#{line}' at line #{@src.lineno}"
  end

  def command_type
    @current_command&.type
  end

  def symbol
    # TODO
    raise NotImplementedError
  end

  def dest
    # TODO: no Guard for Command other than C.
    @current_command.dest
  end

  def comp
    # TODO: no Guard for Command other than C.
    @current_command.comp
  end

  def jump
    # TODO: no Guard for Command other than C.
    @current_command.jump
  end

  private

  def advance_internal
    @current_line = read_with_normalize
    while !@src.closed? && (@current_line.empty? || @current_line.match(/^\/\//))
      @current_line = read_with_normalize
    end
  end

  def read_with_normalize
    return @src.readline.gsub(/\r|\n|\s/, '')
  rescue EOFError
    @src.close
  end
end

class Command
  def initialize
    raise NotImplementedError, 'do not initialize this abstruct command directly.'
  end

  def type
    raise NotImplementedError, 'implent this method in each child class.'
  end
end

class ACommand < Command
  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def type
    return "A_COMMAND"
  end
end

class CCommand < Command
  attr_accessor :dest, :comp, :jump

  def initialize(dest, comp, jump)
    @dest = dest
    @comp = comp
    @jump = jump
  end

  def type
    return "C_COMMAND"
  end
end
