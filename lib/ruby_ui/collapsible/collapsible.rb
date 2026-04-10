# frozen_string_literal: true

module RubyUI
  class Collapsible
    include ComponentBase

    def initialize(open: false, **attrs)
      @open = open
      super(**attrs)
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
