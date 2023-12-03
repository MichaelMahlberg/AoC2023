require 'minitest/autorun'

Sample_input_day1 = %Q(
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
).split

Sample_results_day1 = %Q(
12
38
15
77
).split

Sample_input_day1_p2 = %Q(
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
).split

Sample_results_day1_p2 = %Q(
29
83
13
24
42
14
76
).split

Sample_sum_d1p1 = 142

Sample_sum_d1p2 = 281


Desired_substitutions = [
  ["zero", "0" ],
  ["one", "1" ],
  ["two", "2" ],
  ["three", "3" ],
  ["four", "4" ],
  ["five", "5" ],
  ["six", "6" ],
  ["seven", "7" ],
  ["eight", "8" ],
  ["nine", "9" ] ]

Desired_substitutions_reversed = [
  ["zero".reverse, "0" ],
  ["one".reverse, "1" ],
  ["two".reverse, "2" ],
  ["three".reverse, "3" ],
  ["four".reverse, "4" ],
  ["five".reverse, "5" ],
  ["six".reverse, "6" ],
  ["seven".reverse, "7" ],
  ["eight".reverse, "8" ],
  ["nine".reverse, "9" ] ]

def parse_from_left( input_line)
  parse_from_left_withArray( input_line, Desired_substitutions)
end

def parse_from_left_withArray(input_line, digitArray)
  pos = input_line.length
  result = 0
  digitArray.each do |digit|
    digit_as_text_pos = input_line.index(digit[0])
    digit_as_digit_pos = input_line.index(digit[1])
    if digit_as_text_pos && (digit_as_text_pos < pos)
      pos = digit_as_text_pos
      result = digit[1].to_i
    end
    if digit_as_digit_pos && (digit_as_digit_pos < pos)
      pos = digit_as_digit_pos
      result = digit[1].to_i
    end
  end
  result
end

def parse_from_right(input_line)
  parse_from_left_withArray(input_line.reverse, Desired_substitutions_reversed)
end

class FindingTheDigits < Minitest::Test
  def test_line_with_no_numbers
    assert(parse_from_left("abcdefg") == 0, "i'll just interpret this as a zero for now")
  end

  def test_find_number_from_the_left
    assert_equal(3, parse_from_left("asb324asd"), "should find the 3")
    assert_equal(7, parse_from_left("treb7uchet"), "should find the 7")
  end

  def test_find_number_from_the_right
    assert_equal(4, parse_from_right("asb324asd"), "should find the 4")
    assert_equal(4, parse_from_right("asb324"), "should find the 4")
    assert_equal(7, parse_from_right("treb7uchet"), "should find the 7")
  end
end

def evaluate_line(the_line)
  parse_from_left(the_line) * 10 + parse_from_right(the_line)
end

class CalculatingTheLines < Minitest::Test
  def simple_number_in_the_middle
    assert_equal( 11, evaluate_line("ab1a1bb"), "simple String wit 11 in the middle")
  end

  def numbers_in_odd_places
    assert_equal( 23, evaluate_line("2b1a1b3"), "2b1a1b3")
    assert_equal( 45, evaluate_line("45"), "45")
  end

  def test_set_from_AoC
    Sample_input_day1.each.with_index do | element, i |
      assert_equal(Sample_results_day1[i].to_i, evaluate_line(element), Sample_results_day1[i])
    end
  end
end

def sum_up_lines( all_the_lines )
  all_the_lines.sum { |item| evaluate_line(item) }
end

class CalculateTotal < Minitest::Test
  def test_from_array
    assert_equal(Sample_sum_d1p1, sum_up_lines(Sample_input_day1 ), Sample_sum_d1p1.to_s )
  end
end

=begin
the_lines = File.readlines("the_data.txt")
final_number = sum_up_lines( the_lines )
puts "Final result: #{final_number}"
=end

class SubstituteWrittenNumbers < Minitest::Test

  def test_set2_from_AoC
    Sample_input_day1_p2.each.with_index do | element, i |
      assert_equal(Sample_results_day1_p2[i].to_i, evaluate_line(element), Sample_results_day1_p2[i])
    end
  end

  def test_set_from_aoc_d1_with_total
    assert_equal( Sample_sum_d1p2, sum_up_lines(Sample_input_day1_p2), "Sample should yiels this number")
  end

end

the_lines = File.readlines("the_data.txt")
final_number = sum_up_lines( the_lines )
puts "Final result: #{final_number}"
