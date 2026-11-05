# frozen_string_literal: true

module RubyUI
  # Root of the popover: scopes the trigger and the content for the Stimulus
  # controller. open: renders it open on load (shadcn's defaultOpen).
  #
  # options: is the older API and still works as a fallback: placement: when
  # PopoverContent gets no side:/align:, and trigger: "hover" when
  # PopoverTrigger gets no open_on_hover:. Without either, the popover opens
  # on click, Enter or Space, as shadcn's does.
  class Popover < Base
    def initialize(open: false, options: {}, **attrs)
      @open = open
      @options = options
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          slot: "popover",
          controller: "ruby-ui--popover",
          ruby_ui__popover_open_value: @open.to_s,
          ruby_ui__popover_options_value: @options.to_json
        }
      }
    end
  end
end
