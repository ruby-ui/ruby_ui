# frozen_string_literal: true

module RubyUI
  class CardFooter < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: 'items-center p-6 pt-0'
      }
    end
  end
end
