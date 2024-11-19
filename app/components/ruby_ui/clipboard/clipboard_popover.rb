# frozen_string_literal: true

module RubyUI
  class ClipboardPopover < Base
    def initialize(type:, **attrs)
      @type = type
      super(**attrs)
    end

    def view_template(&block)
      div(
        class: "hidden",
        style: "width: max-content; position: absolute; top: 0; left: 0;",
        data: {ruby_ui__clipboard_target: clipboard_target}
      ) do
        div(**attrs, &block)
      end
    end

    private

    def clipboard_target
      case @type
      when :success
        "successPopover"
      when :error
        "errorPopover"
      end
    end

    def default_attrs
      {
        data: {
          state: :open
        },
        class: "z-50 rounded-md text-sm border bg-background px-2 py-0.5 text-foreground shadow-md outline-none data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2"
      }
    end
  end
end
