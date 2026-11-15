# frozen_string_literal: true

module RubyUI
  # A muted line under the title: file type and size, progress or an error.
  class AttachmentDescription < Base
    def view_template(&)
      span(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "attachment-description"},
        class: "mt-0.5 block max-w-full min-w-0 truncate text-xs text-muted-foreground " \
          "group-data-[state=error]/attachment:text-destructive/80"
      }
    end
  end
end
