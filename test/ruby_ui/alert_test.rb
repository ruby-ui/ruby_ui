# frozen_string_literal: true

require "test_helper"

class RubyUI::AlertTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
      RubyUI.Alert do
        RubyUI.AlertTitle { "Pro tip" }
        RubyUI.AlertDescription { "Simply, don't include an icon and your alert will look like this." }
      end
    end

    assert_match(/Pro tip/, output)
  end
end
