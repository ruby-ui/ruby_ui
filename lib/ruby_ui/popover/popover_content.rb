# frozen_string_literal: true

module RubyUI
  class PopoverContent < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          ruby_ui__popover_target: 'content'
        },
        class: [
          'hidden z-50 rounded-md border bg-background p-1 text-foreground shadow-md outline-none',
          'data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0',
          'data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95',
          'data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2',
          'data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2',
          'absolute'
        ]
      }
    end
  end
end
