# frozen_string_literal: true

module RubyUI
  class NativeSelectIcon
    include ComponentBase

    private

    def default_attrs
      {
        class: "text-muted-foreground pointer-events-none absolute top-1/2 right-2.5 -translate-y-1/2 select-none"
      }
    end
  end
end
