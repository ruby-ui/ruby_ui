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
        class: "inline-flex h-6 shrink-0 cursor-pointer items-center justify-center rounded px-2 text-xs font-medium bg-foreground/10 text-foreground border-0 ml-auto hover:bg-foreground/15 focus:outline-none focus:ring-2 focus:ring-ring transition-colors"
      }
    end
  end
end
