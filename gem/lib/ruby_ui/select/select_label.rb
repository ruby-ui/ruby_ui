# frozen_string_literal: true

module RubyUI
  class SelectLabel < Base
    # Inside a SelectGroup, the first label names the group.
    def view_template(&)
      names = context[:ruby_ui_select_group]
      return div(**attrs, &) if names.nil? || (!attrs[:id] && names[:labelledby])

      id = attrs[:id] || names[:label_id]
      names[:labelledby] ||= id
      div(**attrs.merge(id: id), &)
    end

    private

    def default_attrs
      {
        # The group is named through aria-labelledby; the text itself is hidden.
        aria: {hidden: "true"},
        data: {slot: "select-label"},
        class: "px-2 py-1.5 text-xs text-muted-foreground"
      }
    end
  end
end
