# frozen_string_literal: true

module RubyUI
  class ToastDescription < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "description"},
        class: "font-normal leading-[1.4] text-muted-foreground"
      }
    end
  end
end
