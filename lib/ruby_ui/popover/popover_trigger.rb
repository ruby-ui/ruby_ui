# frozen_string_literal: true

module RubyUI
  class PopoverTrigger
    include ComponentBase

    private

    def default_attrs
      {
        data: {
          ruby_ui__popover_target: "trigger"
        },
        class: "inline-block"
      }
    end
  end
end
