require './parser'


describe "parser" do

  it "parse Add assembly code", :aggregate_failures do
    parser = Parser.new("./spec/Add.asm")

    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("A_COMMAND")
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("C_COMMAND")
    expect(parser.dest).to eq("D")
    expect(parser.comp).to eq("A")
    expect(parser.jump).to be_nil
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("A_COMMAND")
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("C_COMMAND")
    expect(parser.dest).to eq("D")
    expect(parser.comp).to eq("D+A")
    expect(parser.jump).to be_nil
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("A_COMMAND")
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("C_COMMAND")
    expect(parser.dest).to eq("M")
    expect(parser.comp).to eq("D")
    expect(parser.jump).to be_nil
    expect(parser.has_more_commands?).to be(false)
  end
end
