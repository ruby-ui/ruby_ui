# frozen_string_literal: true

module RubyUI
  # Makes the whole Attachment clickable: an invisible <button> (or, with
  # as: :a, a link) stretched over it. The attachment shows its focus ring
  # and hover background; AttachmentActions stay on top and keep working.
  # Give it an aria_label ("Open report.pdf"), since it has no text.
  #
  # shadcn's render prop maps to as: (:button or :a). To open a Dialog, put
  # it inside DialogTrigger.
  class AttachmentTrigger < Base
    def initialize(as: :button, **attrs)
      @as = (as.to_s == "a") ? :a : :button
      super(**attrs)
    end

    def view_template(&)
      send(@as, **attrs, &)
    end

    private

    def default_attrs
      attrs = {
        data: {slot: "attachment-trigger"},
        class: "absolute inset-0 z-10 outline-none"
      }
      attrs[:type] = "button" if @as == :button
      attrs
    end
  end
end
