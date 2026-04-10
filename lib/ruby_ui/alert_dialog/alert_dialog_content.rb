# frozen_string_literal: true

module RubyUI
  class AlertDialogContent
    include ComponentBase

    private

    def default_attrs
      {
        data: {
          ruby_ui__alert_dialog_target: "content"
        }
      }
    end
  end
end
