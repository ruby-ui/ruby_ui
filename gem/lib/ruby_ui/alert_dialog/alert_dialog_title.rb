# frozen_string_literal: true

module RubyUI
  class AlertDialogTitle < Base
    def view_template(&)
      h2(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "font-heading text-lg font-medium sm:group-data-[size=default]/alert-dialog-content:group-has-data-[slot=alert-dialog-media]/alert-dialog-content:col-start-2",
        data_ruby_ui__alert_dialog_target: "title"
      }
    end
  end
end
