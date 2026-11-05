# frozen_string_literal: true

module RubyUI
  class SelectLabel < Base
    # Inside a SelectGroup, the first label names the group.
    def view_template(&)
      names = context[:ruby_ui_select_group]
      return div(**attrs, &) if names.nil? || (!attrs[:id] && names[:labelledby])

      id = attrs[:id] || names[:label_id]
      names[:labelledby] ||= id
      # The group is named through aria-labelledby, so this text is hidden to
      # avoid reading it twice. Other labels stay in the accessibility tree.
      div(**mix({aria: {hidden: "true"}}, attrs.merge(id: id)), &)
    end

    private

    def default_attrs
      {
        data: {slot: "select-label"},
        class: "px-2 py-1.5 text-xs text-muted-foreground"
      }
    end
  end
end
