# frozen_string_literal: true

require "test_helper"

class RubyUI::PopoverTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
      RubyUI.Popover do
        RubyUI.PopoverTrigger(class: "w-full") do
          RubyUI.Button(variant: :outline) { "Open Popover" }
        end
        RubyUI.PopoverContent(class: "w-40") do
          RubyUI.Link(href: "#", variant: :ghost, class: "block w-full justify-start pl-2") do |link|
            link.plain "Profile"
          end
          RubyUI.Link(href: "#", variant: :ghost, class: "block w-full justify-start pl-2") do |link|
            link.plain "Settings"
          end
          RubyUI.Link(href: "#", variant: :ghost, class: "block w-full justify-start pl-2") do |link|
            link.plain "Logout"
          end
        end
      end
    end

    assert_match(/Profile/, output)
  end
end
