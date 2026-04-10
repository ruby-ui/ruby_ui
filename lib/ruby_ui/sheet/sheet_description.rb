# frozen_string_literal: true

module RubyUI
  class SheetDescription
    include ComponentBase

    private

    def default_attrs
      {
        class: "text-sm text-muted-foreground"
      }
    end
  end
end
