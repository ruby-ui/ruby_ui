# frozen_string_literal: true

module RubyUI
  class ToastTitle < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "title"},
        class: "text-sm font-medium leading-tight"
      }
    end
  end
end
