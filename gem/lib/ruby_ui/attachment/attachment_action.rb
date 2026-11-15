# frozen_string_literal: true

module RubyUI
  # An icon button for an Attachment (remove, download, copy link…). A RubyUI
  # Button that defaults to variant: :ghost and size: :icon_xs, as shadcn's
  # AttachmentAction does; it takes every Button option, href: included.
  # Give it an aria_label naming the file.
  class AttachmentAction < Button
    def initialize(variant: :ghost, size: :icon_xs, **attrs)
      super
    end

    private

    def default_attrs
      super.tap { |attrs| attrs[:data][:slot] = "attachment-action" }
    end
  end
end
