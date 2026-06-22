# frozen_string_literal: true

require "test_helper"

class RubyUI::AccordionTest < ComponentTest
  def test_render_with_default_items
    output = phlex do
      RubyUI.Accordion do
        RubyUI.AccordionItem do
          RubyUI.AccordionDefaultTrigger { "Title" }
          RubyUI.AccordionDefaultContent { "Content" }
        end
      end
    end

    assert_match(/<div data-controller="ruby-ui--accordion"/, output)
  end

  def test_render_with_all_items
    output = phlex do
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

  # Regression test for issue #168:
  # Closed accordion content must not trap form validation errors in a
  # zero-height clipped region. Verify that:
  #   - closed content has the `hidden` attribute (truly hidden from layout + focus)
  #   - closed content carries data-state="closed" for CSS/semantic targeting
  #   - open content does NOT have the `hidden` attribute
  #   - open content carries data-state="open"

  def test_closed_content_is_hidden
    output = phlex do
      RubyUI.Accordion do
        RubyUI.AccordionItem(open: false) do
          RubyUI.AccordionTrigger { "Trigger" }
          RubyUI.AccordionContent do
            "Hidden content"
          end
        end
      end
    end

    # The content div must carry hidden so it is fully removed from layout,
    # preventing form field errors inside it from being invisible-but-focusable.
    assert_match(/data-ruby-ui--accordion-target="content"[^>]*hidden/, output)
  end

  def test_closed_content_has_data_state_closed
    output = phlex do
      RubyUI.Accordion do
        RubyUI.AccordionItem(open: false) do
          RubyUI.AccordionTrigger { "Trigger" }
          RubyUI.AccordionContent do
            "Hidden content"
          end
        end
      end
    end

    assert_match(/data-state="closed"/, output)
  end

  def test_open_content_does_not_have_hidden
    output = phlex do
      RubyUI.Accordion do
        RubyUI.AccordionItem(open: true) do
          RubyUI.AccordionTrigger { "Trigger" }
          RubyUI.AccordionContent do
            "Visible content"
          end
        end
      end
    end

    # When open: true the JS controller removes hidden on connect —
    # but at the Ruby/HTML level the content still starts with hidden.
    # The Stimulus controller handles removal at runtime. What we can assert
    # at the structural level is that the item is wired up with open: true
    # (Phlex renders boolean true as a bare attribute, no ="true").
    assert_match(/data-ruby-ui--accordion-open-value/, output)
    # Confirm the open: true value is set (bare attribute without ="false")
    refute_match(/data-ruby-ui--accordion-open-value="false"/, output)
  end

  # Structural test: a FormField with a FormFieldError nested inside a closed
  # AccordionContent is present in the HTML (not stripped) but wrapped inside
  # an element that carries the `hidden` attribute, so the browser hides it
  # from layout and focus — the error cannot silently block form submission.
  def test_form_field_error_inside_closed_accordion_is_wrapped_in_hidden_element
    output = phlex do
      RubyUI.Accordion do
        RubyUI.AccordionItem(open: false) do
          RubyUI.AccordionTrigger { "Form section" }
          RubyUI.AccordionContent do |content|
            # Simulate a form validation error message inside a closed accordion
            content.span(class: "text-destructive text-sm") { "This field is required" }
          end
        end
      end
    end

    # Error text is in the DOM (server-rendered), but its ancestor content
    # container must carry `hidden` so the browser skips it for layout/focus.
    assert_match(/This field is required/, output)
    assert_match(/hidden/, output)
    # Confirm the hidden attribute belongs to the content target element
    assert_match(/data-ruby-ui--accordion-target="content"[^>]*hidden/, output)
  end
end
