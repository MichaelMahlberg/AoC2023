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