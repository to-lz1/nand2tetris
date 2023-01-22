#! /usr/bin/env ruby
require './parser'
require './code'

def assemble(source_path)
  parser = Parser.new(source_path)
  output_name = File.basename(source_path).gsub(File.extname(source_path), '.hack')

  File.open("hack/#{output_name}", "w") { |f|
    while parser.has_more_commands? do
      parser.advance
      command_type = parser.command_type
      case command_type
      when 'A_COMMAND'
        code_val = parser.address
      when 'C_COMMAND'
        dest = Code.dest(parser.dest)
        comp = Code.comp(parser.comp)
        jump = Code.jump(parser.jump)
        code_val = 0b111 << 13 | comp << 6 | dest << 3 | jump
      end
      f.write(code_val.to_s(2).rjust(16, '0') + "\n")
    end
  }
end

if $0 == __FILE__
  assemble(ARGV[0])
end
