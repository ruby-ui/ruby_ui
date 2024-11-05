# frozen_string_literal: true

require "test_helper"

class RubyUI::TooltipTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
      RubyUI.Tooltip do
        RubyUI.TooltipTrigger do
          RubyUI.Button(variant: :outline, icon: true) { "?" }
        end
        RubyUI.TooltipContent do
          RubyUI::Text(as: "p") { "Add to library" }
        end
      end
    end

    assert_match(/Add to library/, output)
  end
end
