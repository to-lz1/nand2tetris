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

    return bit1 << 2 | bit2 << 1 | bit3
  end

  def comp(mnemonic)
    return 0b0000000
  end

  def jump(mnemonic)
    return 0b000
  end
end