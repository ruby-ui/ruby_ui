# frozen_string_literal: true

require "test_helper"

class RubyUI::PaginationTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
      RubyUI.Pagination do
        RubyUI.PaginationContent do
          RubyUI.PaginationItem(href: "#") do |item|
            item.plain "First"
          end
          RubyUI.PaginationItem(href: "#") do |item|
            item.plain "Prev"
          end

          RubyUI.PaginationEllipsis

          RubyUI.PaginationItem(href: "#") { "4" }
          RubyUI.PaginationItem(href: "#", active: true) { "5" }
          RubyUI.PaginationItem(href: "#") { "6" }

          RubyUI.PaginationEllipsis

          RubyUI.PaginationItem(href: "#") do |item|
            item.plain "Next"
          end
          RubyUI.PaginationItem(href: "#") do |item|
            item.plain "Last"
          end
        end
      end
    end

    assert_match(/First/, output)
  end
end
