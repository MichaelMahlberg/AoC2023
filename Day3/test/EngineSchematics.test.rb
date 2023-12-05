require 'minitest/autorun'
require_relative '../engine_schematic_solver.rb'

class WalkingThroughTheLines < Minitest::Test
  def setup
    @myLines = "....123....\n....234....\n....345....\n"
    @solver = EngineSchematicSolver.new
  end

  def test_moving_window
    actual_windows = []
    @solver.move_window_over(@myLines) do |a,b,c|
      actual_windows << [a,b,c]
    end
    assert_equal( [["","....123....","....234...."],
                   ["....123....","....234....","....345...."],
                   ["....234....","....345....",""]], actual_windows )
  end

  def test_find_one_number_in_line
    expected = Possible_engine_part_number.new( 124,4,3).to_s
    actual = @solver.findNumbersInLine(
      "....124....")[0].to_s
    assert_equal( expected, actual )
  end
  def test_find_two_numbers_in_line
    expected = [
      Possible_engine_part_number.new( 124,4,3).to_s,
      Possible_engine_part_number.new( 24,11,2).to_s
    ]
    actual = @solver.findNumbersInLine(
      #                      01234567890123456789
      "....124....24..").map {|x| x.to_s}
    assert_equal( expected, actual )
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
  # It shoudl_find
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
      assert_equal(false, @solver.is_there_an_adjacent_symbol(entry, 4, 3) )
    end
  end

  [
    "...x.......",
    "....x......",
    ".....x.....",
    "......x....",
    ".......x..."].each do |data|
    define_method("test_it_should_find_#{data}") do
      assert_equal(true, @solver.is_there_an_adjacent_symbol(data, 4, 3) )
    end
  end

  def test_identify_machine_part_in_one_frame

    frame = [
      "..........",
      "...123....",
      ".........."]

    assert_equal( [],
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

    assert_equal( 123,
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
    "top_left" =>
      ["....x.............",
       ".....123..........",
       "..................", [123]],
    "bottom_right_hash" =>
      ["..................",
       ".....123..........",
       "........#.........", [123]],
    "two_numberst" =>
      ["....x.............",
       ".....123..456.....",
       ".........$........", [123, 456]],
    "two_numberst_one_symbol" =>
      ["..........23......",
       ".....123.456......",
       "........$.........", [123, 456]],
    "two_numberst_no_symbol" =>
      ["..................",
       ".........23.......",
       ".....123.456......", []]


  }.each do |entry|
    define_method("test_find_#{entry[0]}") do
      assert_equal( entry[1][3],
                    @solver.find_machine_parts_in_frame(
                      entry[1][0],
                      entry[1][1],
                      entry[1][2]
                    ) );
    end
  end


end