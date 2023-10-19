# frozen_string_literal: true

class CommandDialogContent < ApplicationComponent
  def initialize(**attributes)
    @attributes = attributes
  end

  def template(&block)
    template_tag(data: { dialog_target: "content" }) do
      div(data: { controller: 'dismissable' }) do
        div(
          data_state: "open",
          data_action: "click->dismissable#dismiss",
          class:
            "fixed inset-0 z-50 bg-background/80 backdrop-blur-sm data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
          style: "pointer-events:auto",
        )
        div(
            **@attributes,
            data_state: "open",
            class: tokens("fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%] gap-4 border bg-background shadow-lg duration-200 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[state=closed]:slide-out-to-left-1/2 data-[state=closed]:slide-out-to-top-[48%] data-[state=open]:slide-in-from-left-1/2 data-[state=open]:slide-in-from-top-[48%] sm:rounded-lg md:w-full overflow-hidden p-0", @attributes[:class]),
            style: "pointer-events:auto"
        ) do
            yield
        end
      end
    end
  end
end
