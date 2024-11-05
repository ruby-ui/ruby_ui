# frozen_string_literal: true

require "test_helper"

class RubyUI::BadgeTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
      RubyUI.Badge { "Badge" }
    end

    assert_match(/Badge/, output)
  end
end
