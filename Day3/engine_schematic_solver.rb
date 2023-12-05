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

  def to_s
    "v:#{@value.to_s} s:#{@start.to_s} l:#{@length.to_s}"
  end
end

class EngineSchematicSolver
  def findNumbersInLine(engine_schematics_as_line)
    engine_schematics_as_line.enum_for(:scan, /[0-9]+/)
      .map do
      Possible_engine_part_number.new(
            $~.to_s,
            $~.begin(0),
            $~.end(0)-$~.begin(0)
                   )
    end
  end

  def setup_last_line
    ""
  end

  # Would be much more readable as a class, but that's
  # so terribly inefficient...
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
    move_window_over( engine_schematics_as_lines ) do |last, current, following|
      line_number += 1
      numbers = findNumbersInLine(current)


      puts "line_number: #{line_number}\n" +
             "window: ---\n" +
             "- «#{last}»\n" +
             "> «#{current}»\n" +
             "+ «#{following}»\n" +
             "-----"
    end




=begin
    numbers_in_line.each { |potential_part_number|
      look_for_adjacent_symbol_in_previous_line( potential_part_number.start, potential_part_number.length )
      look_for_adjacent_symbol_in_current_line( potential_part_number.start, potential_part_number.length )
      look_for_adjacent_symbol_in_next_line( potential_part_number.start, potential_part_number.length )
    }
=end
  end

  def is_there_an_adjacent_symbol(entry, start, length)
    partial = entry[start-1,length+2]
    !(/[^0-9\.]/ =~ partial).nil?
  end
end
