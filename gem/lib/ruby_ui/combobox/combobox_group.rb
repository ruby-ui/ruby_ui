# frozen_string_literal: true

module RubyUI
  # A group of items, named by the ComboboxLabel inside it. The controller
  # hides it while none of its items matches the search.
  class ComboboxGroup < Base
    def initialize(id: nil, **)
      @id = id || "combobox-group-#{SecureRandom.hex(4)}"
      super(id: @id, **)
    end

    def view_template(&)
      previous = context[:ruby_ui_combobox_group]
      context[:ruby_ui_combobox_group] = {label_id: "#{@id}-label"}
      div(**attrs, &)
    ensure
      context[:ruby_ui_combobox_group] = previous
    end

    private

    def default_attrs
      {
        role: "group",
        aria: {labelledby: "#{@id}-label"},
        data: {slot: "combobox-group", ruby_ui__combobox_target: "group"}
      }
    end
  end
end
