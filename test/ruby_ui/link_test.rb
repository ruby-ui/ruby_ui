# frozen_string_literal: true

require "test_helper"

class RubyUI::LinkTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Link(href: "#") { "Link" }
    end

    assert_match(/Link/, output)
  end
end
