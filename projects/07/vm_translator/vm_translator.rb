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
    when 'C_LABEL'
      writer.write_label(parser.arg1)
    when 'C_GOTO'
      writer.write_goto(parser.arg1)
    when 'C_IF'
      writer.write_if(parser.arg1)
    when 'C_CALL'
      writer.write_call(parser.arg1, parser.arg2)
    when 'C_RETURN'
      writer.write_return
    when 'C_FUNCTION'
      writer.write_function(parser.arg1, parser.arg2)
    else
      raise ArgumentError, "invalid command type. command type: #{parser.command_type}"
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
