# frozen_string_literal: true

module RubyUI
  class CardDescription < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "card-description"},
        class: "text-sm text-muted-foreground"
      }
    end
  end
end
