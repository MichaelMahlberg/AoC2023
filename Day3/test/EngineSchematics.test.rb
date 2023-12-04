require 'minitest/autorun'
require_relative '../engine_schematic_solver.rb'

class WalkingThroughTheLines < Minitest::Test
  def setup
    @myLines = "....123....\n....234....\n....345....\n"
  end

  def test_first_line_gets_skipped
    solver = EngineSchematicSolver.new
    solver.getGrandTotal(@myLines)
  end
end