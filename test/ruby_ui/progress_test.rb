# frozen_string_literal: true

require "test_helper"

class RubyUI::ProgressTest < ComponentTest
  def test_render
    output = phlex do
      RubyUI::Progress(value: 50)
    end

    assert_match(/aria-valuemin="0"/, output)
    assert_match(/aria-valuemax="100"/, output)
    assert_match(/aria-valuenow="50.0"/, output)
    assert_match(/aria-valuetext="50.0%"/, output)
    assert_match(/translateX\(-50.0%\)/, output)
  end
end
