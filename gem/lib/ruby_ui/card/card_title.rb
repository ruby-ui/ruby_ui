# frozen_string_literal: true

module RubyUI
  class CardTitle < Base
    def view_template(&)
      h3(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "font-semibold leading-none tracking-tight"
      }
    end
  end
end
