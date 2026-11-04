# frozen_string_literal: true

module RubyUI
  class NativeSelectOption < Base
    def view_template(&)
      option(**attrs, &)
    end

    private

    # System colors keep options readable in the browser's native picker,
    # whatever the page's color scheme.
    def default_attrs
      {
        data: {slot: "native-select-option"},
        class: "bg-[Canvas] text-[CanvasText]"
      }
    end
  end
end
