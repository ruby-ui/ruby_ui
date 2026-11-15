# frozen_string_literal: true

module RubyUI
  # A row of Attachments that scrolls sideways, snapping to each one, with the
  # edges faded while there is more to scroll (scroll-fade-x from the install
  # CSS).
  class AttachmentGroup < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "attachment-group"},
        class: "flex min-w-0 scroll-fade-x snap-x snap-mandatory scrollbar-none gap-3 overflow-x-auto overscroll-x-contain scroll-px-1 py-1 " \
          "*:data-[slot=attachment]:flex-none *:data-[slot=attachment]:snap-start"
      }
    end
  end
end
