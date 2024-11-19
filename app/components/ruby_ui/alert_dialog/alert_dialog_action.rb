# frozen_string_literal: true

module RubyUI
  class AlertDialogAction < Base
    def view_template(&)
      render RubyUI::Button.new(**attrs, &)
    end

    private

    def default_attrs
      {
        variant: :primary
      }
    end
  end
end
