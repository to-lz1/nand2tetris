require './symbol_table'


describe "symbol_table" do

  it "contains pre-defined symbols", :aggregate_failures do
    table = SymbolTable.new

    expect(table.contains?('SP')).to be(true)
    expect(table.contains?('R0')).to be(true)
    expect(table.contains?('R15')).to be(true)
    expect(table.contains?('KBD')).to be(true)

    expect(table.get_address('SP')).to be(0)
    expect(table.get_address('LCL')).to be(1)
    expect(table.get_address('ARG')).to be(2)
    expect(table.get_address('THIS')).to be(3)
    expect(table.get_address('THAT')).to be(4)
    expect(table.get_address('R0')).to be(0)
    expect(table.get_address('R1')).to be(1)
    expect(table.get_address('R2')).to be(2)
    expect(table.get_address('R3')).to be(3)
    expect(table.get_address('R4')).to be(4)
    expect(table.get_address('R5')).to be(5)
    expect(table.get_address('R6')).to be(6)
    expect(table.get_address('R7')).to be(7)
    expect(table.get_address('R8')).to be(8)
    expect(table.get_address('R9')).to be(9)
    expect(table.get_address('R10')).to be(10)
    expect(table.get_address('R11')).to be(11)
    expect(table.get_address('R12')).to be(12)
    expect(table.get_address('R13')).to be(13)
    expect(table.get_address('R14')).to be(14)
    expect(table.get_address('R15')).to be(15)
    expect(table.get_address('SCREEN')).to be(16384)
    expect(table.get_address('KBD')).to be(24576)
  end

  it "returns whether a key is defined" do
    table = SymbolTable.new
    expect(table.contains?('FOO')).to be(false)
  end

  it "add entries" do
    table = SymbolTable.new
    key = 'BAR'
    table.add_entry(key, 128)
    expect(table.get_address(key)).to be(128)
  end
end
