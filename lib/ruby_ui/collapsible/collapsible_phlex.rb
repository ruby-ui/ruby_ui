# frozen_string_literal: true

module RubyUI
  class Collapsible < Base
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
          controller: "ruby-ui--collapsible",
          ruby_ui__collapsible_open_value: @open
        }
      }
    end
  end
end
