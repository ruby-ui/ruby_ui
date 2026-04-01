# frozen_string_literal: true

module RubyUI
  class DialogDescription < Base
    def view_template(&)
      p(**attrs, &)
    end

    private

    def default_attrs
      {
        class: 'text-sm text-muted-foreground'
      }
    end
  end
end
