# frozen_string_literal: true

class AlertDialogContent < ApplicationComponent
  def initialize()
  end
  
  def template
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
          style: "pointer-events:auto"
        ) do
          div(class: "flex flex-col space-y-2 text-center sm:text-left") do
            h2(id: "radix-:r4o:", class: "text-lg font-semibold") do
              "Are you absolutely sure?"
            end
            p(id: "radix-:r4p:", class: "text-sm text-muted-foreground") do
              "This action cannot be undone. This will permanently delete your account and remove your data from our servers."
            end
          end
          div(class: "flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2") do
            button(
              type: "button",
              class: "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 border border-input bg-transparent shadow-sm hover:bg-accent hover:text-accent-foreground h-9 px-4 py-2 mt-2 sm:mt-0",
              data: { action: 'click->dismissable#dismiss' }
            ) { "Cancel" }
            button(
              type: "button",
              class:
                "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground shadow hover:bg-primary/90 h-9 px-4 py-2"
            ) { "Continue" }
          end
        end
      end
    end
  end
end
