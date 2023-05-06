#! /usr/bin/env ruby
# frozen_string_literal: true

require './code_writer'
require './parser'
require 'optparse'

def translate(source_dir, skip_init)

  vm_files = Dir.glob("#{source_dir}/*.vm")
  raise "ERROR: There is no .vm files in #{source_dir}!" if vm_files.empty?

  output_name = output_file_path(source_dir)
  writer = CodeWriter.new
  writer.set_file_name(output_name)
  writer.write_init unless skip_init

  vm_files.each { |vm_file|

    parser = Parser.new(vm_file)

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
  }

  writer.close
end

def output_file_path(source_dir)
  basename = File.basename(source_dir) + '.asm'
  File.join(source_dir, basename)
end

# usage: ./vm_translator.rb path/of/directory/including_some_vm_files
if $PROGRAM_NAME == __FILE__
  skip_init = false

  opt = OptionParser.new
  opt.on('--skip-init', desc='skip writing init code') { skip_init = true }
  opt.parse(ARGV)

  translate(ARGV[0], skip_init)
end
