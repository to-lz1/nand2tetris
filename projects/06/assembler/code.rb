module Code
  module_function

  def dest(mnemonic)
    if mnemonic.nil?
      return 0b000
    end

    if !mnemonic.match(/[AMD]+/)
      raise ArgumentError.new("invalid input as dest: #{mnemonic}")
    end

    bit1 = mnemonic.include?('A') ? 1 : 0
    bit2 = mnemonic.include?('D') ? 1 : 0
    bit3 = mnemonic.include?('M') ? 1 : 0

    bit1 << 2 | bit2 << 1 | bit3
  end

  def comp(mnemonic)
    case mnemonic
    when '0'
      c1_6 = 0b101010
    when '1'
      c1_6 = 0b111111
    when '-1'
      c1_6 = 0b111010
    when 'D'
      c1_6 = 0b001100
    when 'A', 'M'
      c1_6 = 0b110000
    when '!D'
      c1_6 = 0b001101
    when '!A', '!M'
      c1_6 = 0b110001
    when '-D'
      c1_6 = 0b001111
    when '-A', '-M'
      c1_6 = 0b110011
    when 'D+1'
      c1_6 = 0b011111
    when 'A+1', 'M+1'
      c1_6 = 0b110111
    when 'D-1'
      c1_6 = 0b001110
    when 'A-1', 'M-1'
      c1_6 = 0b110010
    when 'D+A', 'D+M'
      c1_6 = 0b000010
    when 'D-A', 'D-M'
      c1_6 = 0b010011
    when 'A-D', 'M-D'
      c1_6 = 0b000111
    when 'D&A', 'D&M'
      c1_6 = 0b000000
    when 'D|A', 'D|M'
      c1_6 = 0b010101
    else
      raise ArgumentError.new("invalid input as comp: #{mnemonic}")
    end

    a = mnemonic.match?(/M/) ? 0b1 : 0b0
    a << 6 | c1_6
  end

  def jump(mnemonic)
    if mnemonic.nil?
      return 0b000
    end

    if !mnemonic.match?(/J[(GT)(EQ)(GE)(LT)(LE)(NE)(MP)]/)
      raise ArgumentError.new("invalid input as jmp: #{mnemonic}")
    end

    bit1 = mnemonic.match?(/L/) ? 0b1 : 0b0
    bit2 = mnemonic.match?(/E/) ? 0b1 : 0b0
    bit3 = mnemonic.match?(/G/) ? 0b1 : 0b0

    result = bit1 << 2 | bit2 << 1 | bit3
    mnemonic.match?(/[NM]/) ? result ^ 0b111 : result
  end
end