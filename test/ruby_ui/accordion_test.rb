# frozen_string_literal: true

require "test_helper"

class RubyUI::AccordionTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_default_items
    output = phlex_context do
      RubyUI.Accordion do
        RubyUI.AccordionItem do
          RubyUI.AccordionDefaultTrigger { "Title" }
          RubyUI.AccordionDefaultContent { "Content" }
        end
      end
    end

    assert_match(/<div data-controller="ruby_ui--accordion"/, output)
  end

  def test_render_with_all_items
    output = phlex_context do
      RubyUI.Accordion do
        RubyUI.AccordionItem do
          RubyUI.AccordionTrigger do |trigger|
            trigger.div do |div|
              RubyUI.AccordionIcon do |icon|
                icon.svg(
                  xmlns: "http://www.w3.org/2000/svg",
                  fill: "none",
                  viewbox: "0 0 24 24",
                  stroke_width: "1.5",
                  stroke: "currentColor",
                  class: "w-6 h-6"
                ) do |s|
                  s.path(
                    stroke_linecap: "round",
                    stroke_linejoin: "round",
                    d: "M12 9v6m3-3H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"
                  )
                end
              end
              div.p { "What is RubyUI?" }
            end
          end

          RubyUI.AccordionContent do |content|
            content.p { "RubyUI is a UI component library for Ruby devs who want to build better, faster." }
          end
        end

        RubyUI.AccordionItem do
          RubyUI.AccordionTrigger do |trigger|
            trigger.div do |div|
              RubyUI.AccordionIcon do |icon|
                icon.svg(
                  xmlns: "http://www.w3.org/2000/svg",
                  fill: "none",
                  viewbox: "0 0 24 24",
                  stroke_width: "1.5",
                  stroke: "currentColor",
                  class: "w-6 h-6"
                ) do |s|
                  s.path(
                    stroke_linecap: "round",
                    stroke_linejoin: "round",
                    d: "M12 9v6m3-3H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"
                  )
                end
              end
              div.p { "Can I use it with Rails?" }
            end
          end

          RubyUI.AccordionContent do |content|
            content.p do
              "Yes, RubyUI is pure Ruby and works great with Rails. It's a Ruby gem that you can install into your Rails app."
            end
          end
        end
      end
    end

    assert_match(/Yes, RubyUI is pure Ruby and works great with Rails/, output)
  end
end
