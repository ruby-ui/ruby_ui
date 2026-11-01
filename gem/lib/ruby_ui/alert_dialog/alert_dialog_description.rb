# frozen_string_literal: true

module RubyUI
  class AlertDialogDescription < Base
    # Inside AlertDialogContent the description describes the dialog (aria-describedby).
    def view_template(&)
      names = context[:ruby_ui_alert_dialog]
      return p(**attrs, &) unless names

      id = attrs[:id] || "#{names[:id]}-description"
      names[:describedby] ||= id
      p(**attrs.merge(id: id), &)
    end

    private

    def default_attrs
      {
        class: "text-sm text-balance text-muted-foreground md:text-pretty *:[a]:underline *:[a]:underline-offset-3 *:[a]:hover:text-foreground"
      }
    end
  end
end
