# frozen_string_literal: true

module RubyUI
  # Groups ContextMenuRadioItems: checking one unchecks the others. Like
  # ContextMenuGroup, a ContextMenuLabel inside it names the group.
  class ContextMenuRadioGroup < ContextMenuGroup
    private

    def default_attrs
      {
        role: "group",
        data: {slot: "context-menu-radio-group"}
      }
    end
  end
end
