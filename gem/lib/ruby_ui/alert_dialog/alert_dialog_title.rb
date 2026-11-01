# frozen_string_literal: true

module RubyUI
  class AlertDialogTitle < Base
    # Inside AlertDialogContent the title names the dialog (aria-labelledby).
    def view_template(&)
      names = context[:ruby_ui_alert_dialog]
      return h2(**attrs, &) unless names

      id = attrs[:id] || "#{names[:id]}-title"
      names[:labelledby] ||= id
      h2(**attrs.merge(id: id), &)
    end

    private

    def default_attrs
      {
        class: "font-heading text-lg font-medium sm:group-data-[size=default]/alert-dialog-content:group-has-data-[slot=alert-dialog-media]/alert-dialog-content:col-start-2"
      }
    end
  end
end
