# frozen_string_literal: true

module RubyUI
  class AlertDialogContent < Base
    def view_template(&block)
      template(**attrs) do
        div(data: {controller: "ruby-ui--alert-dialog"}) do
          background
          container(&block)
        end
      end
    end

    def background
      div(
        data_state: "open",
        class: "fixed inset-0 z-50 bg-black/80 backdrop-blur-sm data-[state=open]:animate-in",
        style: "pointer-events:auto",
        data_aria_hidden: "true",
        aria_hidden: "true"
      )
    end

    def container(&)
      div(
        role: "alertdialog",
        data_state: "open",
        class: "flex flex-col fixed left-[50%] top-[50%] z-50 w-full max-w-lg max-h-screen overflow-y-auto translate-x-[-50%] translate-y-[-50%] gap-4 border bg-background p-6 shadow-lg duration-200 data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95 sm:rounded-lg md:w-full",
        style: "pointer-events:auto",
        &
      )
    end

    private

    def default_attrs
      {
        data: {
          ruby_ui__alert_dialog_target: "content"
        }
      }
    end
  end
end
