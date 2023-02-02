class SymbolTable
  def initialize
    @hash = {}
    add_entry('SP', 0x0000)
    add_entry('LCL', 0x0001)
    add_entry('ARG', 0x0002)
    add_entry('THIS', 0x0003)
    add_entry('THAT', 0x0004)
    (0..15).each { |n|
      add_entry("R#{n}", n)
    }
    add_entry('SCREEN', 0x4000)
    add_entry('KBD', 0x6000)
  end

  def add_entry(symbol, address)
    @hash[symbol] = address
  end

  def contains?(symbol)
    @hash.has_key?(symbol)
  end

  def get_address(symbol)
    @hash[symbol]
  end
end
