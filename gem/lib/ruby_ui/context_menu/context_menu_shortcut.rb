# frozen_string_literal: true

module RubyUI
  class ContextMenuShortcut < Base
    def view_template(&)
      span(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "context-menu-shortcut"},
        class: "ml-auto text-xs tracking-widest text-muted-foreground group-focus/context-menu-item:text-accent-foreground"
      }
    end
  end
end
