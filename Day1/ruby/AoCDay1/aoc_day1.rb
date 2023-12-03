require 'minitest/autorun'

Sample_input = %Q(
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
).split

Sample_results = %Q(
12
38
15
77
).split

Sample_sum = 142

def parse_from_left(input_line)
  pos = input_line =~/[0-9]/;
  pos == nil ? 0 : input_line[pos].to_i ;
end

def parse_from_right(input_line)
  parse_from_left(input_line.reverse)
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
    Sample_input.each.with_index do | element, i |
      assert_equal( Sample_results[i].to_i, evaluate_line(element), Sample_results[i])
    end
  end
end

def sum_up_lines( all_the_lines )
  all_the_lines.sum { |item| evaluate_line(item) }
end
class CalculateTotal < Minitest::Test
  def test_from_array
    assert_equal( Sample_sum, sum_up_lines( Sample_input ), Sample_sum.to_s )
  end
end

the_lines = File.readlines("the_data.txt")
final_number = sum_up_lines( the_lines )
puts "Final result: #{final_number}"