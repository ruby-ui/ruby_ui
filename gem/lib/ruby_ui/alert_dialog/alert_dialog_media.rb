# frozen_string_literal: true

module RubyUI
  class AlertDialogMedia < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    # data-slot drives the header's media layout (has-data-[slot=alert-dialog-media]).
    def default_attrs
      {
        data: {slot: "alert-dialog-media"},
        class: "bg-muted mb-2 inline-flex size-16 items-center justify-center rounded-md sm:group-data-[size=default]/alert-dialog-content:row-span-2 *:[svg:not([class*='size-'])]:size-8"
      }
    end
  end
end
