# frozen_string_literal: true

module RubyUI
  class AlertDialogFooter < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "flex flex-col-reverse gap-2 group-data-[size=sm]/alert-dialog-content:grid group-data-[size=sm]/alert-dialog-content:grid-cols-2 sm:flex-row sm:justify-end"
      }
    end
  end
end
