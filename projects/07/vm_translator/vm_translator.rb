#! /usr/bin/env ruby
# frozen_string_literal: true

require './code_writer'
require './parser'

def translate(source_path)
  parser = Parser.new(source_path)
  output_name = output_file_path(source_path)

  writer = CodeWriter.new
  writer.set_file_name(output_name)

  while parser.has_more_commands?
    parser.advance
    case parser.command_type
    when 'C_ARITHMETIC'
      writer.write_arithmetic(parser.arg1)
    when 'C_POP', 'C_PUSH'
      writer.write_push_pop(parser.command_type, parser.arg1, parser.arg2)
    end
  end

  writer.close
end

def output_file_path(source_path)
  dirname = File.dirname(source_path)
  basename = File.basename(source_path).gsub(File.extname(source_path), '.asm')
  File.join(dirname, basename)
end

translate(ARGV[0]) if $PROGRAM_NAME == __FILE__
