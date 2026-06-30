# frozen_string_literal: true

module RubyUI
  class MessageGroup < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "message-group"},
        class: "flex min-w-0 flex-col gap-2"
      }
    end
  end
end
