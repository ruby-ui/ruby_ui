# frozen_string_literal: true

module RubyUI
  class ToastCancel < Base
    def initialize(label:, **attrs)
      @label = label
      super(**attrs)
    end

    def view_template
      button(**attrs) { @label }
    end

    private

    def default_attrs
      {
        type: "button",
        data: {
          slot: "cancel",
          action: "click->ruby-ui--toast#dismiss"
        },
        class: "inline-flex h-8 shrink-0 cursor-pointer items-center justify-center rounded-md px-3 text-sm font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
      }
    end
  end
end
