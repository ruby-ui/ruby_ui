# frozen_string_literal: true

module RubyUI
  class TabsList < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "inline-flex h-9 items-center justify-center rounded-lg bg-muted p-1 text-muted-foreground"
      }
    end
  end
end
