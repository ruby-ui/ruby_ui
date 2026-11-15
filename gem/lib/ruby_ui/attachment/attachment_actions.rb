# frozen_string_literal: true

module RubyUI
  # Holds the AttachmentAction buttons. Sits above an AttachmentTrigger, so
  # its buttons stay clickable; on a vertical attachment it floats over the
  # top-right corner of the media.
  class AttachmentActions < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "attachment-actions"},
        class: "relative z-20 flex shrink-0 items-center " \
          "group-data-[orientation=vertical]/attachment:absolute group-data-[orientation=vertical]/attachment:top-3 " \
          "group-data-[orientation=vertical]/attachment:right-3 group-data-[orientation=vertical]/attachment:gap-1"
      }
    end
  end
end
