# frozen_string_literal: true

require "test_helper"

class RBUI::InlineLinkTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_inline_link
    output = phlex_context do
      RBUI::InlineLink(href: "#") { "Link" }
    end

    assert_match(/Link/, output)
    assert_match(/href="#"/, output)
    assert_match(/text-primary/, output)
    assert_match(/font-medium/, output)
    assert_match(/hover:underline/, output)
  end
end
