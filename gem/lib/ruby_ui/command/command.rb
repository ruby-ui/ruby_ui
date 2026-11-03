# frozen_string_literal: true

module RubyUI
  # Root of a command menu (shadcn's Command). Works inline on the page or
  # inside CommandDialogContent. Typing in CommandInput filters the items; the
  # first visible item is active, arrow keys, Home and End move the active item
  # and Enter selects it. loop: true lets the arrow keys wrap around.
  class Command < Base
    def initialize(loop: false, **attrs)
      @loop = loop
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "flex size-full flex-col overflow-hidden rounded-xl! bg-popover p-1 text-popover-foreground",
        data: {
          slot: "command",
          controller: "ruby-ui--command",
          ruby_ui__command_loop_value: @loop.to_s
        }
      }
    end
  end
end
