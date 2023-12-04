# frozen_string_literal: true

class Possible_engine_part_number
  attr_accessor :value
  attr_accessor :start
  attr_accessor :length

  def initialize( value, start, length )
    @value=value
    @start=start
    @length=length
  end
end

class EngineSchematicSolver
  def findNumbersInLine(engine_schematics_as_lines)
    [ Possible_engine_part_number.new(123, 4, 3)]
  end

  def setup_last_line
    ""
  end

  def move_window_over( all_the_lines )
    current_line=""
    next_line=""
    processor_is_warm = false
    all_the_lines.each_line do |line_to_process|
      if not processor_is_warm
        processor_is_warm = true
        current_line = ""
        next_line = line_to_process.strip
        next
      end

      last_line = current_line
      current_line = next_line
      next_line = line_to_process.strip

      yield last_line, current_line, next_line

    end
    last_line = current_line
    current_line = next_line
    next_line = ""
    yield last_line, current_line, next_line

  end

  def getGrandTotal( engine_schematics_as_lines )
    line_number=0
    move_window_over( engine_schematics_as_lines ) do |last_line, current_line, next_line|
      line_number += 1
      puts "line_number: #{line_number}\n" +
             "window: ---\n" +
             "- «#{last_line}»\n" +
             "> «#{current_line}»\n" +
             "+ «#{next_line}»\n" +
             "-----"
    end
    puts "finding out the grand total"



=begin
    current_line= engine_schematics_as_lines.
    numbers_in_line = findNumbersInLine( engine_schematics_as_lines )
    numbers_in_line.each { |potential_part_number|
      look_for_adjacent_symbol_in_previous_line( potential_part_number.start, potential_part_number.length )
      look_for_adjacent_symbol_in_current_line( potential_part_number.start, potential_part_number.length )
      look_for_adjacent_symbol_in_next_line( potential_part_number.start, potential_part_number.length )
    }

    last_line
    current_line
    next_line
=end
  end
end
