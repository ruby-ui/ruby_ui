# frozen_string_literal: true

module RubyUI
  class ComboboxBadge < Base
    def view_template(&)
      span(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "inline-flex items-center gap-1 rounded-md border bg-secondary px-1.5 py-0.5 text-xs font-medium text-secondary-foreground"
      }
    end
  end
end
