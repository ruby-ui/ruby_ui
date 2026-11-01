# frozen_string_literal: true

require "securerandom"

module RubyUI
  # Groups AccordionItems. Single-open by default: every item shares the same
  # <details name>, so the browser closes the others when one opens.
  class Accordion < Base
    def initialize(multiple: false, disabled: false, **attrs)
      @multiple = multiple
      @disabled = disabled
      super(**attrs)
    end

    def view_template(&)
      previous = context[:ruby_ui_accordion]
      context[:ruby_ui_accordion] = {
        name: (@multiple ? nil : "ruby-ui-accordion-#{SecureRandom.hex(4)}"),
        disabled: @disabled
      }
      div(**attrs, &)
    ensure
      context[:ruby_ui_accordion] = previous
    end

    private

    def default_attrs
      {
        data: {slot: "accordion"},
        class: "flex w-full flex-col"
      }
    end
  end
end
