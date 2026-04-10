# frozen_string_literal: true

module RubyUI
  class ContextMenuLabel
    include ComponentBase

    def initialize(inset: false, **attrs)
      @inset = inset
      super(**attrs)
    end

    private

    def default_attrs
      {
        class: ["px-2 py-1.5 text-sm font-semibold text-foreground", (@inset ? "pl-8" : nil)].compact
      }
    end
  end
end
