# frozen_string_literal: true

require "securerandom"

module RubyUI
  # A group of items (role group), named by the DropdownMenuLabel inside it.
  class DropdownMenuGroup < Base
    def initialize(id: nil, **)
      @id = id || "dropdown-menu-group-#{SecureRandom.hex(4)}"
      super(id: @id, **)
    end

    # The children are captured first, so aria-labelledby only points at a
    # DropdownMenuLabel that actually rendered.
    def view_template(&block)
      previous = context[:ruby_ui_dropdown_menu_group]
      names = context[:ruby_ui_dropdown_menu_group] = {label_id: "#{@id}-label"}
      body = block ? capture(&block) : ""
      group_attrs = names[:labelledby] ? mix({aria: {labelledby: names[:labelledby]}}, attrs) : attrs
      div(**group_attrs) { raw(safe(body)) }
    ensure
      context[:ruby_ui_dropdown_menu_group] = previous
    end

    private

    def default_attrs
      {
        role: "group",
        data: {slot: "dropdown-menu-group"}
      }
    end
  end
end
