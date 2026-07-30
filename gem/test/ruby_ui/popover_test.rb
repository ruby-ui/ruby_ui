# frozen_string_literal: true

require "test_helper"

class RubyUI::PopoverTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
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

  # The animation classes on the content are keyed on data-state, so the
  # attribute has to be present before the Stimulus controller ever runs.
  def test_content_renders_closed_state_by_default
    output = phlex do
      RubyUI.PopoverContent { "popover body" }
    end

    assert_match(/data-state="closed"/, output)
    assert_match(/hidden/, output)
    assert_match(/absolute/, output)
    assert_match(/popover body/, output)
  end
end
