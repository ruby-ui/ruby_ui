# frozen_string_literal: true

module RubyUI
  class AlertDialogTrigger < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          ruby_ui__alert_dialog_target: "trigger",
          action: "click->ruby-ui--alert-dialog#open"
        },
        class: "inline-block"
      }
    end
  end
end
