
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
  def find_numbers_in_line(engine_schematics_as_line)
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
    !(/[^0-9.]/ =~ partial).nil?
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
    find_numbers_in_line(current_line).each do |number|
      [previous_line, current_line,upcoming_line].each do |line|
        if adjacent_symbol?(
          line, number.start, number.length
        )
          found_items << number.value
          break
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

  def adjacent_number(the_potential_gear, the_line)
    adjacent = []
    x = the_potential_gear.x
    numbers = find_numbers_in_line(the_line )
    numbers.each do |number|
      adjacent << number.value if gear_text_adjacent?(number, x)
    end
    adjacent
  end

  def gear_numbers_in_frame(before, actual, after)
    all_gear_numbers = []
    find_stars_in_line(actual).each do |a_star|
      star_gear_numbers = []
      star_gear_numbers += adjacent_number(a_star, before)
      star_gear_numbers += adjacent_number(a_star, actual)
      star_gear_numbers += adjacent_number(a_star, after)

      all_gear_numbers << star_gear_numbers
    end
    all_gear_numbers
  end

  def gear_power_for(before, current, upcoming)
    power = 0
    gear_numbers = gear_numbers_in_frame( before,
                                          current,
                                          upcoming)
    gear_numbers.each do |star_numbers|
      power += star_numbers.size == 2 ? star_numbers.reduce(:*) : 0
    end
    power
  end

  def all_gear_powers(the_lines)
    the_powers = []
    move_window_over(the_lines) do |before, current, after|
      this_lines_gear_powers = gear_power_for(before, current, after)
      if this_lines_gear_powers > 0
        the_powers << this_lines_gear_powers
      end
    end
    the_powers
  end

  def gear_powers_sum(the_lines)
    all_gear_powers(the_lines).reduce( :+ )
  end

  private

  def gear_text_adjacent?(number, x)
    (
      (x >= (number.start - 1)) &&
      (x <= (number.start + number.length))
      )
  end

end

solver = EngineSchematicSolver.new
lines = File.open("SampleEngineSchematics.txt")
puts "\nSample Data summed « "+solver.machine_parts_sum(lines).to_s+" »\n"
lines.close
lines = File.open("SampleEngineSchematics.txt")
puts "\nSample Data Gear-Values summed « "+solver.gear_powers_sum(lines).to_s+" »\n"
lines.close
lines = File.open("EngineSchematics.txt")
puts "\nReal Data summed« "+solver.machine_parts_sum(lines).to_s+" »\n"
lines.close
lines = File.open("EngineSchematics.txt")
puts "\nReal Data Gear-Values summed « "+solver.gear_powers_sum(lines).to_s+" »\n"
lines.close
