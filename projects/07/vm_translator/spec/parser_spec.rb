require './parser'


describe "parser" do

  it "parse SimpleAdd vm code", :aggregate_failures do
    parser = Parser.new("./spec/SimpleAdd.vm")

    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("C_PUSH")
    expect(parser.arg1).to eq("constant")
    expect(parser.arg2).to eq(7)
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("C_PUSH")
    expect(parser.arg1).to eq("constant")
    expect(parser.arg2).to eq(8)
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("C_ALITHMETIC")
    expect(parser.arg1).to eq("add")
    expect(parser.arg2).to be_nil
    expect(parser.has_more_commands?).to be(false)
  end
end
