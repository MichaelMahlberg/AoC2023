require 'minitest/autorun'
require_relative '../engine_schematic_solver.rb'

$test_mode = true

class WalkingThroughTheLines < Minitest::Test
  def setup
    @my_lines = "....123....\n....234....\n....345....\n"
    @solver = EngineSchematicSolver.new
  end

  def test_moving_window
    actual_windows = []
    @solver.move_window_over(@my_lines) do |a, b, c|
      actual_windows << [a, b, c]
    end
    assert_equal([["", "....123....", "....234...."],
                  ["....123....", "....234....", "....345...."],
                  ["....234....", "....345....", ""]], actual_windows)
  end

  def test_find_one_number_in_line
    expected = PossibleEnginePartNumber.new(124, 4, 3).to_s
    actual = @solver.find_numbers_in_line(
      "....124....")[0].to_s
    assert_equal(expected, actual)
  end

  def test_find_one_number_at_start_of_line
    expected = PossibleEnginePartNumber.new(124, 0, 3).to_s
    actual = @solver.find_numbers_in_line(
      "124........")[0].to_s
    assert_equal(expected, actual)
  end

  def test_find_two_numbers_in_line
    expected = [
      PossibleEnginePartNumber.new(124, 4, 3).to_s,
      PossibleEnginePartNumber.new(24, 11, 2).to_s
    ]
    actual = @solver.find_numbers_in_line(
      #                      01234567890123456789
      "....124....24..").map { |x| x.to_s }
    assert_equal(expected, actual)
  end

end

class FindingSymbols < Minitest::Test
  def setup
    @solver = EngineSchematicSolver.new
  end

  # Explanations
  # 0123456789012345
  # ....123.... => s=5, l=3
  # It should_not_find
  # ..x........
  # .........x.
  # ...........
  # It should_find
  # ...x.......
  # ....x......
  # .....x.....
  # ..---.x....
  # ..---..x...
  # @solver.is_adjacent_symbol(

  [
    "..x........",
    ".........x."
  ].each do |entry|
    define_method("test_it_should_not_find_#{entry}") do
      assert_equal(false, @solver.adjacent_symbol?(entry, 4, 3))
    end
  end

  [
    "...x.......",
    "....x......",
    ".....x.....",
    "......x....",
    ".......x..."].each do |data|
    define_method("test_it_should_find_#{data}") do
      assert_equal(true, @solver.adjacent_symbol?(data, 4, 3))
    end
  end

  def test_identify_machine_part_in_one_frame

    frame = [
      "..........",
      "...123....",
      ".........."]

    assert_equal([],
                 @solver.find_machine_parts_in_frame(
                   frame[0],
                   frame[1],
                   frame[2])
    )
  end

  def test_identify_machine_part_in_one_frame_with_symbol

    frame = [
      "..........",
      "...123x...",
      ".........."]

    assert_equal(123,
                 @solver.find_machine_parts_in_frame(
                   frame[0],
                   frame[1],
                   frame[2])[0]
    )
  end

  {
    :outside =>
      ["...x...............",
       "......123..........",
       "...................", []],
    :top_left =>
      ["....x.............",
       ".....123..........",
       "..................", [123]],
    :bottom_right_hash =>
      ["..................",
       ".....123..........",
       "........#.........", [123]],
    :two_numbers =>
      ["....x.............",
       ".....123..456.....",
       ".........$........", [123, 456]],
    :two_numbers_one_symbol =>
      ["..........23......",
       ".....123.456......",
       "........$.........", [123, 456]],
    :two_numbers_no_symbol =>
      ["..................",
       ".........23.......",
       ".....123.456......", []]

  }.each do |entry|
    define_method("test_find_#{entry[0]}") do
      assert_equal(entry[1][3],
                   @solver.find_machine_parts_in_frame(
                     entry[1][0],
                     entry[1][1],
                     entry[1][2]
                   ))
    end
  end

  {
    "617" => ["617*......\n" +
                "..........\n" +
                "............", [617]],
    "617_at_the_end" => ["618*......\n" +
                        "........x.\n" +
                        ".........617", [618, 617]],
    "2x3x4" => ["1x.......x........\n" +
                  "1x......x2x.......\n" +
                  ".....#3..4........", [1, 1, 2, 3, 4]],
    # 125*2130*12*21
    "125*2130*12*21" => ["..125.............\n" +
                           "...^.....2130§....\n" +
                           "..12...21x.......", [125, 2130, 12, 21]]
  }.each do |key, parms|
    define_method("test_all_parts_#{key}") do
      assert_equal(parms[1], @solver.collect_machine_parts(parms[0]))
    end
  end

  [
    ["2+3+4",
     "..................\n" +
       ".........2x.......\n" +
       ".....#3..4........",
     9],
    # 125*2130*12*21
    ["125+2130+12+21",
     "..125.............\n" +
       "...^.....2130§....\n" +
       "..12...21x.......",
     2288]
  ].each do |name, lines, result|
    define_method("test_sum_#{name}") do
      assert_equal(result, @solver.machine_parts_sum(lines))
    end

  end

end

class AoC_SampleDataSummedUp < Minitest::Test
  def test_the_sample_data
    solver = EngineSchematicSolver.new
    lines = File.open("SampleEngineSchematics.txt")
    assert_equal(4361, solver.machine_parts_sum(lines))
  end

end

class FindStars < Minitest::Test
  def setup
    @solver = EngineSchematicSolver.new

    @frame_for_zero = ["...1...23..",
                       "...1.*.1...",
                       ".543....121"]
    @frame_for_six  = ["...1.23..",
                       "...1*1...",
                       ".543.121"]
    @frame_for_two  = ["...1.23..",
                       "...1.*.1...",
                       ".543.121"]
    @frame_for_two_in_line = [
      "...*............569#..496........888.............227......*..67......*..................877........*...#.......*.......716......975....@....",
      "...730........................$...#..112............*..509..*.......858..710.......@567..%..610..821...918..................................",
      ".........794.....701@..456-...505.....*............884.....298...............................&...............742=.....95...................."]

  end

  def test_finding_stars
    assert_equal(7, @solver.find_stars_in_line(".......*..")[0].x)
    assert_equal(2, @solver.find_stars_in_line("..*....*..")[0].x)
    assert_equal(7, @solver.find_stars_in_line("..*....*..")[1].x)
    assert_equal([2, 5, 9], @solver.find_stars_in_line("..*1.*.78*..").map { |s| s.x })
  end

  def test_check_for_adjacent_number_left
    a_potential_gear = Potential_gear.new(5)
    #        "012345678"
    a_line = "...12...."
    assert_equal([12], @solver.adjacent_number(a_potential_gear, a_line))
  end

  def test_check_for_adjacent_number_right
    a_potential_gear = Potential_gear.new(5)
    #        "01234*678"
    a_line = "......12."
    assert_equal([12], @solver.adjacent_number(a_potential_gear, a_line))
    #        "01234*678"
    a_line = ".......12"
    assert_equal([], @solver.adjacent_number(a_potential_gear, a_line))
  end

  def test_check_for_adjacent_number_between
    a_potential_gear = Potential_gear.new(5)
    #        "01234*678"
    a_line = "....1212."
    assert_equal([1212], @solver.adjacent_number(a_potential_gear, a_line))
    #        "01234*678"
    a_line = "..1......."
    assert_equal([],@solver.adjacent_number(a_potential_gear, a_line))
  end

  def test_check_for_adjacent_number_edges
    a_potential_gear = Potential_gear.new(5)
    #        "012345678"
    a_line = "....12"
    assert_equal([12], @solver.adjacent_number(a_potential_gear, a_line))

    a_line = "..1......."
    assert_equal([], @solver.adjacent_number(a_potential_gear, a_line))

    a_potential_gear = Potential_gear.new(1)
    ["1.....", ".1...."].each do |a_line|
      assert(@solver.adjacent_number(a_potential_gear, a_line), a_line)
    end
  end

  def test_check_for_adjacent_number_both_sides
    a_potential_gear = Potential_gear.new(5)
    #        "012345678"
    a_line = "12.....12"
    assert_equal([], @solver.adjacent_number(a_potential_gear, a_line))

    [ ["..123.456.", [123,456]],
      ["....7.9...", [7,9]] ].each do |a_line, a_result|
      assert_equal(a_result, @solver.adjacent_number(a_potential_gear, a_line), a_line)
    end
  end

  def test_check_with_little_distance
    #"01234567890"
    ["..11.*.....",
     "...1.*.2..."].each { |a_line|
      a_potential_gear = @solver.find_stars_in_line(a_line)[0]
      assert_equal(5, a_potential_gear.x)
      assert_equal([], @solver.adjacent_number(a_potential_gear,
                                               a_line), a_line)
    }
  end


  def test_collect_adjacent_in_frame_for_none
      assert_equal( [] ,
                     @solver.gear_numbers_in_frame(@frame_for_zero[0],
                                                   @frame_for_zero[1],
                                                   @frame_for_zero[2]))

    end

  def test_collect_adjacent_in_frame_for_many
    assert_equal( [1,23,1,1,543,121] ,
                  @solver.gear_numbers_in_frame(@frame_for_six[0],
                                                @frame_for_six[1],
                                                @frame_for_six[2]))

    assert_equal( [23,121] ,
                  @solver.gear_numbers_in_frame(@frame_for_two[0],
                                                @frame_for_two[1],
                                                @frame_for_two[2]))

    assert_equal( [[227,884],[67,298]],
                  @solver.gear_numbers_in_frame(@frame_for_two_in_line[0],
                                                @frame_for_two_in_line[1],
                                                @frame_for_two_in_line[2]))

  end

  def test_gear_number_two_stars_one_line

  end


  def test_power_for_gears
    assert_equal(0,@solver.gear_power_for(@frame_for_zero[0],
                                          @frame_for_zero[1],
                                          @frame_for_zero[2]))
    assert_equal(2783,@solver.gear_power_for(@frame_for_two[0],
                                          @frame_for_two[1],
                                          @frame_for_two[2]))
    assert_equal(0,@solver.gear_power_for(@frame_for_six[0],
                                          @frame_for_six[1],
                                          @frame_for_six[2]))
  end

  def test_move_frame_for_gears
    sample = File.readlines("SampleEngineSchematics.txt").join("\r")
    assert_equal( [16345, 451490], @solver.all_gear_powers(sample))
  end
  def test_Calculate_sum
    sample = File.readlines("SampleEngineSchematics.txt").join("\r")
    assert_equal( 467835, @solver.gear_powers_sum(sample))
  end


end