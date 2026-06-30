# frozen_string_literal: true

module RubyUI
  class MessageFooter < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "message-footer"},
        class: "flex max-w-full min-w-0 items-center px-3 text-xs font-medium text-muted-foreground group-data-[align=end]/message:justify-end group-has-data-[variant=ghost]/message:px-0"
      }
    end
  end
end
