# frozen_string_literal: true

module RubyUI
  class Dialog < Base
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
          controller: "ruby-ui--dialog",
          ruby_ui__dialog_open_value: @open
        }
      }
    end
  end
end
