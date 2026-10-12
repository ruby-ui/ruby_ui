# frozen_string_literal: true

module RubyUI
  class Drawer < Base
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
          controller: "ruby-ui--drawer",
          ruby_ui__drawer_open_value: @open.to_s
        }
      }
    end
  end
end
