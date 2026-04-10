# frozen_string_literal: true

module RubyUI
  class AlertDialogTrigger
    include ComponentBase

    private

    def default_attrs
      {
        data: {action: "click->ruby-ui--alert-dialog#open"},
        class: "inline-block"
      }
    end
  end
end
