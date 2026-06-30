# frozen_string_literal: true

module RubyUI
  class MessageAvatar < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "message-avatar"},
        class: "flex w-fit min-w-8 shrink-0 items-center justify-center self-end overflow-hidden rounded-full bg-muted group-has-data-[slot=message-footer]/message:-translate-y-8"
      }
    end
  end
end
