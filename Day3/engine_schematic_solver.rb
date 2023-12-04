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

  def getGrandTotal( engine_schematics_as_lines )

    last_line = setup_last_line()
    engine_schematics_as_lines.each_line do |line_to_process|
      if processor_is_warm.nil?
        processor_is_warm = true
        next_line = line_to_process
        next
      end
    end

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
  end
end
