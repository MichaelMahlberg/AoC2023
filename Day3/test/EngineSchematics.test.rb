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
    actual = @solver.findNumbersInLine(
      "....124....")[0].to_s
    assert_equal(expected, actual)
  end

  def test_find_one_number_at_start_of_line
    expected = PossibleEnginePartNumber.new(124, 0, 3).to_s
    actual = @solver.findNumbersInLine(
      "124........")[0].to_s
    assert_equal(expected, actual)
  end

  def test_find_two_numbers_in_line
    expected = [
      PossibleEnginePartNumber.new(124, 4, 3).to_s,
      PossibleEnginePartNumber.new(24, 11, 2).to_s
    ]
    actual = @solver.findNumbersInLine(
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

class AoC_SampleData < Minitest::Test
  def test_the_sample_data
    solver = EngineSchematicSolver.new
    lines = File.open("SampleEngineSchematics.txt")
    assert_equal(4361, solver.machine_parts_sum(lines))
  end

end

class FindStars < Minitest::Test
  def setup
    @solver = EngineSchematicSolver.new
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
    assert_equal(1, @solver.number_adjacent?(a_potential_gear, a_line))
  end

  def test_check_for_adjacent_number_right
    a_potential_gear = Potential_gear.new(5)
    #        "012345678"
    a_line = "......12."
    assert_equal(1, @solver.number_adjacent?(a_potential_gear, a_line))
    a_line = "........12"
    assert_equal(0, @solver.number_adjacent?(a_potential_gear, a_line))
  end

  def test_check_for_adjacent_number_between
    a_potential_gear = Potential_gear.new(5)
    #        "012345678"
    a_line = "....1212."
    assert_equal(1, @solver.number_adjacent?(a_potential_gear, a_line))
    a_line = "..1......."
    assert_equal(0,@solver.number_adjacent?(a_potential_gear, a_line))
  end

  def test_check_for_adjacent_number_edges
    a_potential_gear = Potential_gear.new(5)
    #        "012345678"
    a_line = "....12"
    assert_equal(1, @solver.number_adjacent?(a_potential_gear, a_line))

    a_line = "..1......."
    assert_equal(0, @solver.number_adjacent?(a_potential_gear, a_line))

    a_potential_gear = Potential_gear.new(1)
    ["1.....", ".1...."].each do |a_line|
      assert(@solver.number_adjacent?(a_potential_gear, a_line),a_line)
    end
  end

  def test_check_for_adjacent_number_both_sides
    a_potential_gear = Potential_gear.new(5)
    #        "012345678"
    a_line = "12.....12"
    assert_equal(0, @solver.number_adjacent?(a_potential_gear, a_line))

    [ "..123.456.",
      "....1.1..."].each do |a_line|
      assert_equal(2, @solver.number_adjacent?(a_potential_gear, a_line), a_line)
    end
  end

end