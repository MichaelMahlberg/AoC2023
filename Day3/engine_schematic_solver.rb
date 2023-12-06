
class PossibleEnginePartNumber
  attr_accessor :value
  attr_accessor :start
  attr_accessor :length

  def initialize( value, start, length )
    @value=value.to_i
    @start=start
    @length=length
  end

  def to_s
    "v:#{@value.to_s} s:#{@start.to_s} l:#{@length.to_s}"
  end
end

class Potential_gear

  attr_reader :x
  def initialize( position )
    @x = position
  end
end

# frozen_string_literal: true
class EngineSchematicSolver
  def findNumbersInLine(engine_schematics_as_line)
    engine_schematics_as_line.enum_for(:scan, /[0-9]+/)
                             .map do
      PossibleEnginePartNumber.new(
        $~.to_s,
        $~.begin(0),
        $~.end(0)-$~.begin(0)
      )
    end
  end

  def find_stars_in_line(the_line)
    the_line.enum_for(:scan, /\*/).map do
      Potential_gear.new($~.begin(0) )
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

  def contains_symbol(partial)
    !(/[^0-9\.]/ =~ partial).nil?
  end

  def adjacent_symbol?(entry, start, length)
    start_margin= start == 0 ? 0 : 1
    end_margin = (start + length) >= entry.length ? 0 : 1

    partial = entry[start-start_margin,
                    length+end_margin+start_margin]
    contains_symbol(partial)
  end

  def find_machine_parts_in_frame(previous_line,
                                  current_line,
                                  upcoming_line)
    found_items = []
    findNumbersInLine(current_line).each do |number|
      [previous_line, current_line,upcoming_line].each do |line|
        if adjacent_symbol?(
          line, number.start, number.length
        )
          found_items << number.value
          break;
        end

      end
    end
    found_items
  end

  def collect_machine_parts(the_lines)
    values=[]
    move_window_over(the_lines) do |prev, curr, nxt|
      intermediate = find_machine_parts_in_frame(prev, curr, nxt)
      # puts "Intermediate = «#{intermediate}»" unless $test_mode == true
      values += intermediate
    end
  end

  def machine_parts_sum(the_lines)
    collect_machine_parts(the_lines).inject(:+)
  end

  def number_adjacent?(the_potential_gear, the_line)
    adjecent = 0
    x = the_potential_gear.x
    numbers = findNumbersInLine( the_line )
    numbers.each do |number|
      adjecent += 1 if gear_text_adjacent?(number, x)
    end
    return adjecent
  end

  private

  def gear_text_adjacent?(number, x)
    (x >= number.start - 1 &&
      x <= number.start + number.length + 1)
  end

end

solver = EngineSchematicSolver.new
lines = File.open("SampleEngineSchematics.txt")
puts "\nSample Data « "+solver.machine_parts_sum(lines).to_s+" »\n"
lines.close
lines = File.open("EngineSchematics.txt")
puts "\nReal Data « "+solver.machine_parts_sum(lines).to_s+" »\n"
lines.close





