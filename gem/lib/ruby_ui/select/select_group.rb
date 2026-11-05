# frozen_string_literal: true

require "securerandom"

module RubyUI
  # A group of items, named by the SelectLabel inside it (role=group with
  # aria-labelledby, as Base UI's Select.Group).
  class SelectGroup < Base
    def initialize(id: nil, **)
      @id = id || "select-group-#{SecureRandom.hex(4)}"
      super(id: @id, **)
    end

    # The children are captured first, so aria-labelledby only points at a
    # SelectLabel that actually rendered.
    def view_template(&block)
      previous = context[:ruby_ui_select_group]
      names = context[:ruby_ui_select_group] = {label_id: "#{@id}-label"}
      body = block ? capture(&block) : ""
      group_attrs = names[:labelledby] ? mix({aria: {labelledby: names[:labelledby]}}, attrs) : attrs
      div(**group_attrs) { raw(safe(body)) }
    ensure
      context[:ruby_ui_select_group] = previous
    end

    private

    def default_attrs
      {
        role: "group",
        data: {slot: "select-group"},
        class: "scroll-my-1 p-1"
      }
    end
  end
end
