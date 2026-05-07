# frozen_string_literal: true

module RubyUI
  class ContextMenuLabel < Base
    def initialize(inset: false, **attrs)
      @inset = inset
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def inset? = @inset

    def default_attrs
      {
        class: ["px-2 py-1.5 text-sm font-semibold text-foreground", inset?: "pl-8"]
      }
    end
  end
end
