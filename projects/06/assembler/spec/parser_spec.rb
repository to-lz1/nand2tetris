require './parser'


describe "parser" do

  it "parse Add assembly code without symbol", :aggregate_failures do
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

  it "parse assembly code with symbol", :aggregate_failures do
    parser = Parser.new("./spec/Max.asm")

    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("A_COMMAND")
    expect(parser.symbol).to eq("R0")
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("C_COMMAND")
    expect(parser.dest).to eq("D")
    expect(parser.comp).to eq("M")
    expect(parser.jump).to be_nil
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("A_COMMAND")
    expect(parser.symbol).to eq("OUTPUT_FIRST")
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("C_COMMAND")
    expect(parser.dest).to be_nil
    expect(parser.comp).to eq("D")
    expect(parser.jump).to eq("JGT")
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("L_COMMAND")
    expect(parser.symbol).to eq("OUTPUT_FIRST")
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("A_COMMAND")
    expect(parser.symbol).to eq("R0")
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("C_COMMAND")
    expect(parser.dest).to eq("D")
    expect(parser.comp).to eq("M")
    expect(parser.jump).to be_nil
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("L_COMMAND")
    expect(parser.symbol).to eq("INFINITE_LOOP")
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("A_COMMAND")
    expect(parser.symbol).to eq("INFINITE_LOOP")
    expect(parser.has_more_commands?).to be(true)

    parser.advance
    expect(parser.command_type).to eq("C_COMMAND")
    expect(parser.dest).to be_nil
    expect(parser.comp).to eq("0")
    expect(parser.jump).to eq("JMP")
    expect(parser.has_more_commands?).to be(false)
  end
end
