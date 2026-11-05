# frozen_string_literal: true

module RubyUI
  # Groups the keys of a combo (Ctrl + Shift + P), like shadcn's <KbdGroup>.
  # Renders a <kbd>: nested kbd elements represent a key combination.
  class ShortcutKeyGroup < Base
    def view_template(&)
      kbd(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "kbd-group"},
        class: "inline-flex items-center gap-1"
      }
    end
  end
end
