# frozen_string_literal: true

require "test_helper"

class EnumTest < Minitest::Test
  class Sized < RubyUI::Component
    SIZES = {sm: "h-8", md: "h-9", lg: "h-10"}.freeze

    attr_reader :size

    def initialize(size: nil, **attrs)
      @size = enum(size, SIZES, default: :md)
      super(**attrs)
    end
  end

  def test_a_symbol_selects_its_entry
    assert_equal :lg, Sized.new(size: :lg).size
  end

  def test_a_string_is_coerced_to_the_symbol
    assert_equal :lg, Sized.new(size: "lg").size
  end

  def test_nil_takes_the_default
    assert_equal :md, Sized.new.size
    assert_equal :md, Sized.new(size: nil).size
  end

  def test_an_unknown_value_raises_naming_the_allowed_ones
    error = assert_raises(ArgumentError) { Sized.new(size: "xlg") }

    assert_match(/"xlg"/, error.message)
    assert_match(/:sm, :md, :lg/, error.message)
  end

  def test_a_value_that_cannot_be_a_symbol_raises_the_same_way
    error = assert_raises(ArgumentError) { Sized.new(size: 42) }

    assert_match(/42/, error.message)
  end
end
