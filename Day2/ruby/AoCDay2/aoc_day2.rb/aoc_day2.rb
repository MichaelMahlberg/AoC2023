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

def evaluate_line( elven_info)
  game_number, dice_info = getInfoParts(elven_info)
  draws = dice_info.split(";")
  draws.each do |draw|
    dice_sets = draw.split(",")
    dice_sets.each do |dice_set|
      count, color = dice_set.split
    end
  end
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


end