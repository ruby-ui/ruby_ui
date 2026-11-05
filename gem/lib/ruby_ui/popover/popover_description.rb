# frozen_string_literal: true

require "securerandom"

module RubyUI
  # Supporting text. The controller points the content's aria-describedby at it.
  class PopoverDescription < Base
    def view_template(&)
      p(**attrs, &)
    end

    private

    def default_attrs
      {
        id: "popover-description-#{SecureRandom.hex(4)}",
        data: {slot: "popover-description", ruby_ui__popover_target: "description"},
        class: "text-muted-foreground"
      }
    end
  end
end
