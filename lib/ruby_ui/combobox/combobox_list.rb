# frozen_string_literal: true

require "securerandom"

module RubyUI
  class ComboboxList < Base
    def initialize(**attrs)
      @id = "list#{SecureRandom.hex(4)}"
      super
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        id: @id,
        data: {
          ruby_ui__combobox_target: "list"
        },
        role: "listbox",
        tabindex: "-1"
      }
    end
  end
end
