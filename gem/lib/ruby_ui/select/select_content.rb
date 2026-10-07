# frozen_string_literal: true

module RubyUI
  class SelectContent < Component
    def initialize(**attrs)
      @id = "content#{SecureRandom.hex(4)}"
      super
    end

    private

    def default_attrs
      {
        id: @id,
        role: "listbox",
        tabindex: "-1",
        data: {
          ruby_ui__select_target: "content"
        },
        class: "hidden w-full absolute top-0 left-0 z-50"
      }
    end
  end
end
