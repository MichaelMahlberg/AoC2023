require 'minitest/autorun'
require_relative '../engine_schematic_solver.rb'

class WalkingThroughTheLines < Minitest::Test
  def setup
    @myLines = "....123....\n....234....\n....345....\n"
  end

  def test_moving_window
    solver = EngineSchematicSolver.new
    actual_windows = []
    solver.move_window_over(@myLines) do |a,b,c|
      actual_windows << [a,b,c]
    end
    assert_equal( [["","....123....","....234...."],
                   ["....123....","....234....","....345...."],
                   ["....234....","....345....",""]], actual_windows )
  end
end