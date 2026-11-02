# frozen_string_literal: true

module RubyUI
  # A heading. Inside a ContextMenuGroup the first label names the group
  # (aria-labelledby) and its own text is hidden from the accessibility tree.
  class ContextMenuLabel < Base
    def initialize(inset: false, **)
      @inset = inset
      super(**)
    end

    def view_template(&)
      names = context[:ruby_ui_context_menu_group]
      # Only the first label names the group; later ones stay plain headings.
      return div(**attrs, &) if names.nil? || names[:labelledby]

      id = attrs[:id] || names[:label_id]
      names[:labelledby] ||= id
      div(**mix({aria: {hidden: "true"}}, attrs.merge(id: id)), &)
    end

    private

    def default_attrs
      {
        data: {slot: "context-menu-label", inset: @inset},
        class: "text-muted-foreground px-2 py-1.5 text-xs font-medium data-inset:pl-8"
      }
    end
  end
end
