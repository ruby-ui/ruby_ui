# frozen_string_literal: true

module RubyUI
  class AlertDialog < Base
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
          controller: "ruby-ui--alert-dialog",
          ruby_ui__alert_dialog_open_value: @open.to_s
        },
        class: "inline-block"
      }
    end
  end
end
