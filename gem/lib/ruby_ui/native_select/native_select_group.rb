# frozen_string_literal: true

module RubyUI
  class NativeSelectGroup < Base
    def view_template(&)
      optgroup(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "native-select-optgroup"},
        class: "bg-[Canvas] text-[CanvasText]"
      }
    end
  end
end
