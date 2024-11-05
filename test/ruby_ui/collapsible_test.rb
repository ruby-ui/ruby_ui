# frozen_string_literal: true

require "test_helper"

class RubyUI::CollapsibleTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
      RubyUI.Collapsible(open: true) do
        RubyUI.CollapsibleTrigger do
          RubyUI.Button(variant: :ghost, icon: true) do |button|
            button.span(class: "sr-only") { "Toggle" }
          end
        end

        RubyUI.CollapsibleContent do |content|
          content.div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
            "phlex-ruby/phlex-rails"
          end
          content.div(class: "rounded-md border px-4 py-2 font-mono text-sm shadow-sm") do
            "ruby_ui/ruby_ui"
          end
        end
      end
    end

    assert_match(/Toggle/, output)
  end
end
