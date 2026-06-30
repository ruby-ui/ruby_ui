# frozen_string_literal: true

module RubyUI
  class MessageContent < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "message-content"},
        class: "flex w-full min-w-0 flex-col gap-2.5 wrap-break-word group-data-[align=end]/message:[&>[data-slot]]:self-end"
      }
    end
  end
end
