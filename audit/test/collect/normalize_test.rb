require "test_helper"

class CollectNormalizeTest < Minitest::Test
  def norm(value) = ShadcnAudit::Collect::Normalize.value(value)

  def test_rounds_decimals_to_two_places
    assert_equal "0.65", norm("0.6459")
    assert_equal "1.5px", norm("1.50px")
  end

  def test_collapses_whitespace_and_downcases
    assert_equal "rgb(0, 0, 0)", norm("  RGB(0, 0,  0) ")
  end

  def test_integers_unchanged
    assert_equal "10px", norm("10px")
  end

  def test_negative_zero_is_zero
    assert_equal "0px", norm("-0.001px")
  end
end
