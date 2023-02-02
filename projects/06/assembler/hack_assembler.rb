#! /usr/bin/env ruby
require './symbol_table'
require './code'
require './parser'

def assemble(source_path)
  # first path: add entries that represents pseudo command into symbol table
  first_path_parser = Parser.new(source_path)
  address = 0
  symbol_table = SymbolTable.new
  while first_path_parser.has_more_commands? do
    first_path_parser.advance
    case first_path_parser.command_type
    when 'A_COMMAND'
      address = address + 1
    when 'C_COMMAND'
      address = address + 1
    when 'L_COMMAND'
      symbol_table.add_entry(first_path_parser.symbol, address)
    end
  end

  # second path: write code
  parser = Parser.new(source_path)
  output_name = File.basename(source_path).gsub(File.extname(source_path), '.hack')

  variable_address = 16
  File.open("hack/#{output_name}", "w") { |f|
    while parser.has_more_commands? do
      parser.advance
      case parser.command_type
      when 'A_COMMAND'
        if symbol_table.contains?(parser.symbol)
          code_val = symbol_table.get_address(parser.symbol)
        else
          symbol_table.add_entry(parser.symbol, variable_address)
          code_val = variable_address
          variable_address = variable_address + 1
        end
      when 'C_COMMAND'
        dest = Code.dest(parser.dest)
        comp = Code.comp(parser.comp)
        jump = Code.jump(parser.jump)
        code_val = 0b111 << 13 | comp << 6 | dest << 3 | jump
      when 'L_COMMAND'
        next
      end
      f.write(code_val.to_s(2).rjust(16, '0') + "\n")
    end
  }
end

if $0 == __FILE__
  assemble(ARGV[0])
end
