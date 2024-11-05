# frozen_string_literal: true

require "test_helper"

class RubyUI::TabsTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
      RubyUI.Tabs(default_value: "account", class: "w-96") do
        RubyUI.TabsList do
          RubyUI.TabsTrigger(value: "account") { "Account" }
          RubyUI.TabsTrigger(value: "password") { "Password" }
        end
        RubyUI.TabsContent(value: "account") do
          RubyUI::Text(as: "p", size: "4") { "Account" }
          RubyUI::Text(size: "5", weight: "semibold") { "Are you sure absolutely sure?" }
          RubyUI::Text(size: "2", class: "text-muted-foreground") { "Update your account details." }
        end
        RubyUI.TabsContent(value: "password") do
          RubyUI::Text(as: "p", size: "4") { "Password" }
          RubyUI::Text(size: "2", class: "text-muted-foreground") { "Change your password here. After saving, you'll be logged out." }
        end
      end
    end

    assert_match(/Account/, output)
  end
end
