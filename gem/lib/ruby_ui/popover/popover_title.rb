# frozen_string_literal: true

require "securerandom"

module RubyUI
  # The popover's heading. The controller points the content's
  # aria-labelledby at it, so it names the dialog.
  class PopoverTitle < Base
    def view_template(&)
      h2(**attrs, &)
    end

    private

    def default_attrs
      {
        id: "popover-title-#{SecureRandom.hex(4)}",
        data: {slot: "popover-title", ruby_ui__popover_target: "title"},
        class: "font-medium"
      }
    end
  end
end
