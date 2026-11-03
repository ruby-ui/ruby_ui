# frozen_string_literal: true

module RubyUI
  # Groups DropdownMenuRadioItems: checking one unchecks the others. Like
  # DropdownMenuGroup, a DropdownMenuLabel inside it names the group.
  class DropdownMenuRadioGroup < DropdownMenuGroup
    private

    def default_attrs
      {
        role: "group",
        data: {slot: "dropdown-menu-radio-group"}
      }
    end
  end
end
