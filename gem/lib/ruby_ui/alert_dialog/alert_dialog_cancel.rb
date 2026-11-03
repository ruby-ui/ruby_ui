# frozen_string_literal: true

module RubyUI
  class AlertDialogCancel < Base
    def view_template(&)
      render RubyUI::Button.new(**attrs, &)
    end

    private

    def default_attrs
      {
        variant: :outline,
        data: {
          action: "click->ruby-ui--alert-dialog#dismiss"
        }
      }
    end
  end
end
