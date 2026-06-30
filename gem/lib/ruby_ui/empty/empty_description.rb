# frozen_string_literal: true

module RubyUI
  class EmptyDescription < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "empty-description"},
        class: "text-sm leading-relaxed text-muted-foreground [&>a]:underline [&>a]:underline-offset-4 [&>a:hover]:text-primary"
      }
    end
  end
end
