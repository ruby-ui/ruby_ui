# frozen_string_literal: true

class AlertDialogContent < ApplicationComponent  
  def template(&)
    template_tag(data: { alert_dialog_target: "content" }) do
      div(data: { controller: 'dismissable' }) do
        div(
          data_state: "open",
          class:
            "fixed inset-0 z-50 bg-background/80 backdrop-blur-sm data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
          style: "pointer-events:auto",
          data_aria_hidden: "true",
          aria_hidden: "true"
        )
        div(
          role: "alertdialog",
          data_state: "open",
          class: "fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%] gap-4 border bg-background p-6 shadow-lg duration-200 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[state=closed]:slide-out-to-left-1/2 data-[state=closed]:slide-out-to-top-[48%] data-[state=open]:slide-in-from-left-1/2 data-[state=open]:slide-in-from-top-[48%] sm:rounded-lg md:w-full",
          style: "pointer-events:auto",
          &
        )
      end
    end
  end
end
