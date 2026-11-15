# frozen_string_literal: true

module RubyUI
  # The file name. Truncates, and shimmers while the attachment is
  # :uploading or :processing (the shimmer utility from the install CSS).
  class AttachmentTitle < Base
    def view_template(&)
      span(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "attachment-title"},
        class: "block max-w-full min-w-0 truncate font-medium " \
          "group-data-[state=processing]/attachment:shimmer group-data-[state=uploading]/attachment:shimmer"
      }
    end
  end
end
