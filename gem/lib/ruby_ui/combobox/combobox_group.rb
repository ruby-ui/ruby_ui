# frozen_string_literal: true

require "securerandom"

module RubyUI
  # A group of items, named by the ComboboxLabel inside it. The controller
  # hides it while none of its items matches the search.
  class ComboboxGroup < Base
    def initialize(id: nil, **)
      @id = id || "combobox-group-#{SecureRandom.hex(4)}"
      super(id: @id, **)
    end

    # The children are captured first, so aria-labelledby only points at a
    # ComboboxLabel that actually rendered (with its own id: when it has one).
    def view_template(&block)
      previous = context[:ruby_ui_combobox_group]
      names = context[:ruby_ui_combobox_group] = {label_id: "#{@id}-label"}
      body = block ? capture(&block) : ""
      group_attrs = names[:labelledby] ? mix({aria: {labelledby: names[:labelledby]}}, attrs) : attrs
      div(**group_attrs) { raw(safe(body)) }
    ensure
      context[:ruby_ui_combobox_group] = previous
    end

    private

    def default_attrs
      {
        role: "group",
        data: {slot: "combobox-group", ruby_ui__combobox_target: "group"}
      }
    end
  end
end
