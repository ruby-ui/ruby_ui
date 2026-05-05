# frozen_string_literal: true

module RubyUI
  class PopoverTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

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
