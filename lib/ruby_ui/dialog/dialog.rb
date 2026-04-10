# frozen_string_literal: true

module RubyUI
  class Dialog
    include ComponentBase

    def initialize(open: false, **attrs)
      @open = open
      super(**attrs)
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
