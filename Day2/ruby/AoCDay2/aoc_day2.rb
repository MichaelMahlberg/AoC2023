require 'minitest/autorun'

Overall_result_d2p1 = 8

Dice_data_as_string = %Q(
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
)

Available_dice = {
  "red" => 12,
  "green" => 13,
  "blue" => 14
}

def getInfoParts(elven_info)
  info_parts = elven_info.split(":")
  return info_parts[0].split[1].to_i, info_parts[1]
end

def split_draw(the_draw)
  dice_sets = the_draw.split(",").map { |dice_set| dice_set.strip }
end

def split_dice_set(the_set)
  count, color = the_set.split
  return count.to_i, color
end

def is_set_possible?(color, count)
  count <= Available_dice[color]
end

def evaluate_line(elven_info, counter)
  game_number, dice_info = getInfoParts(elven_info)
  return counter if game_number.nil? or dice_info.nil?
  busted = false
  dice_info.split(";").each do |draw|
    split_draw(draw).each do |dice_set|
      count, color = split_dice_set(dice_set)
      if not is_set_possible?(color, count)
        busted = true
      end
    end
  end
  return busted ? counter : counter + game_number
end

def accumulate_game_numbers(the_input)
  result = 0
  the_input.each_line do |line|
    break if line == nil
    result = evaluate_line( line, result)
  end
  return result
end

class ItRejectsImpossibleGames < Minitest::Test
  def test_line_gets_split
    game_number, info_part = getInfoParts("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green")
    assert_equal(1, game_number)
    assert_equal(" 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green", info_part)
    game_number, info_part = getInfoParts("Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red")
    assert_equal(4, game_number)
    assert_equal(" 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red", info_part)
  end

  def test_draws_from_info_part
    game_number, info_part = getInfoParts("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green")
    expected_draws = [" 3 blue, 4 red", " 1 red, 2 green, 6 blue", " 2 green"]
    assert_equal(expected_draws, info_part.split(";"))
  end

  def test_dice_from_draws
    draws = [" 3 blue, 4 red", " 1 red, 2 green, 6 blue", " 2 green"]
    expected_dice_set_from_draw_0 = ["3 blue", "4 red"]
    expected_dice_set_from_draw_1 = ["1 red", "2 green", "6 blue"]
    assert_equal(expected_dice_set_from_draw_0, split_draw(draws[0]))
    assert_equal(expected_dice_set_from_draw_1, split_draw(draws[1]))
  end

  def test_dice_groups_from_dice_sets
    dice_sets = ["1 red", "2 green", "6 blue"]
    count, color = split_dice_set(dice_sets[0])
    assert_equal("red", color)
    assert_equal(1, count)

    count, color = split_dice_set(dice_sets[1])
    assert_equal("green", color)
    assert_equal(2, count)
  end

  def test_rejection_of_red
    assert_equal(true, is_set_possible?("red", 10), "10")
    assert_equal(true, is_set_possible?("red", 12), "12")
    assert_equal(false, is_set_possible?("red", 13), "13")
  end

  def test_counting_line_one
    line = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"
    assert_equal(1, evaluate_line(line, 0))
  end

  def test_counting_line_three
    line = "Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red"
    assert_equal(0, evaluate_line(line, 0))
  end

  def test_counting_line_five
    line = "Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"
    assert_equal(6, evaluate_line(line, 1))
  end


  def test_counting_multiple_lines
    assert_equal(Overall_result_d2p1, accumulate_game_numbers( Dice_data_as_string ))
  end

end

final_result = accumulate_game_numbers(File.open("Real-DiceData-d2p1.txt") )

puts "Final result «#{final_result}»"





