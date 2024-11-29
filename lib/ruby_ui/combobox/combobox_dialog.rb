# frozen_string_literal: true

module RubyUI
  class ComboboxDialog < Base
    BACKDROP_CLASSES = "backdrop:bg-foreground/40"

    def view_template(&)
      dialog(**attrs, &)
    end

    private

    def default_attrs
      {
        class: ["w-11/12 md:w-full md:max-w-md border bg-background shadow-lg rounded-lg", BACKDROP_CLASSES],
        role: "dialog",
        autofocus: true,
        data: {
          ruby_ui__combobox_target: "dialog",
          action: "click->ruby-ui--combobox#handleOutsideClick"
        }
      }
    end
  end
end
