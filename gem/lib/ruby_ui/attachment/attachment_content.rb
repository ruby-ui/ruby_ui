# frozen_string_literal: true

module RubyUI
  # Holds an Attachment's title and description.
  class AttachmentContent < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "attachment-content"},
        class: "max-w-full min-w-0 flex-1 leading-tight group-data-[orientation=vertical]/attachment:px-1"
      }
    end
  end
end
