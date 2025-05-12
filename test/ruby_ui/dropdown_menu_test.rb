# frozen_string_literal: true

require "test_helper"

class RubyUI::DropdownMenuTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.DropdownMenu do
        RubyUI::DropdownMenuOverlay()
        RubyUI.DropdownMenuTrigger(class: "w-full") do
          RubyUI.Button(variant: :outline) { "Open" }
        end
        RubyUI.DropdownMenuContent do
          RubyUI.DropdownMenuLabel { "My Account" }
          RubyUI.DropdownMenuSeparator
          RubyUI.DropdownMenuItem(href: "#") { "Profile" }
          RubyUI.DropdownMenuItem(href: "#") { "Billing" }
          RubyUI.DropdownMenuItem(href: "#") { "Team" }
          RubyUI.DropdownMenuItem(href: "#") { "Subscription" }
        end
      end
    end

    assert_match(/Open/, output)
  end
end
