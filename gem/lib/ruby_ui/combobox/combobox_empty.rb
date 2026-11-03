# frozen_string_literal: true

module RubyUI
  # Shown by CSS while the controller marks the content data-empty (no item
  # matches the search).
  class ComboboxEmpty < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "status",
        aria: {live: "polite", atomic: "true"},
        data: {slot: "combobox-empty"},
        class: "hidden w-full justify-center py-2 text-center text-sm text-muted-foreground group-data-empty/combobox-content:flex"
      }
    end
  end
end
