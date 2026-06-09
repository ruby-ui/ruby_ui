# frozen_string_literal: true

module RubyUI
  class Sheet < Base
    def initialize(open: false, **attrs)
      @open = open
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          controller: "ruby-ui--sheet",
          ruby_ui__sheet_open_value: @open.to_s
        }
      }
    end
  end
end
