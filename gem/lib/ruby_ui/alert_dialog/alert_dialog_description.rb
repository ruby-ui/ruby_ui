# frozen_string_literal: true

module RubyUI
  class AlertDialogDescription < Base
    def view_template(&)
      p(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "text-sm text-balance text-muted-foreground md:text-pretty *:[a]:underline *:[a]:underline-offset-3 *:[a]:hover:text-foreground",
        data_ruby_ui__alert_dialog_target: "description"
      }
    end
  end
end
