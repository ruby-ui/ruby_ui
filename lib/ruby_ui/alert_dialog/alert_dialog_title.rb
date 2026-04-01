# frozen_string_literal: true

module RubyUI
  class AlertDialogTitle < Base
    def view_template(&)
      h2(**attrs, &)
    end

    private

    def default_attrs
      {
        class: 'text-lg font-semibold'
      }
    end
  end
end
