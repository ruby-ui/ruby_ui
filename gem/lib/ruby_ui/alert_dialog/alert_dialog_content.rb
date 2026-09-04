# frozen_string_literal: true

module RubyUI
  class AlertDialogContent < Base
    def view_template(&)
      dialog(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "alertdialog",
        data: {
          ruby_ui__alert_dialog_target: "dialog"
        },
        class: [
          "fixed open:flex flex-col left-[50%] top-[50%] z-50 w-full max-w-lg max-h-screen overflow-y-auto translate-x-[-50%] translate-y-[-50%] gap-4 border bg-background p-6 shadow-lg sm:rounded-lg md:w-full",
          "duration-200 data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 data-[state=closed]:fill-mode-forwards",
          "backdrop:bg-background/80 backdrop:backdrop-blur-sm backdrop:duration-200 data-[state=open]:backdrop:animate-in data-[state=open]:backdrop:fade-in-0 data-[state=closed]:backdrop:animate-out data-[state=closed]:backdrop:fade-out-0 data-[state=closed]:backdrop:fill-mode-forwards"
        ]
      }
    end
  end
end
