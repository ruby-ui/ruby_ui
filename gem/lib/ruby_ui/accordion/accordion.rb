# frozen_string_literal: true

module RubyUI
  class Accordion < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "w-full"
      }
    end
  end
end
