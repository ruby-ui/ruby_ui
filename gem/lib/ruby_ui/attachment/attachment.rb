# frozen_string_literal: true

module RubyUI
  # A file or image attached to a message or form, styled after shadcn's
  # Attachment (Base UI + vega).
  #
  # state: :idle (selected, not sent yet: dashed border), :uploading and
  # :processing (the title shimmers), :error (destructive tint) or :done.
  # size: :default, :sm or :xs. orientation: :horizontal (a row) or :vertical
  # (a tile, e.g. an image preview).
  class Attachment < Base
    STATES = %i[idle uploading processing error done].freeze

    SIZES = {
      default: "gap-2 text-sm has-data-[slot=attachment-media]:p-2 " \
        "has-data-[slot=attachment-content]:px-2.5 has-data-[slot=attachment-content]:py-2",
      sm: "gap-2.5 text-xs has-data-[slot=attachment-media]:p-1.5 " \
        "has-data-[slot=attachment-content]:px-2 has-data-[slot=attachment-content]:py-1.5",
      xs: "gap-1.5 rounded-lg text-xs has-data-[slot=attachment-media]:p-1 " \
        "has-data-[slot=attachment-content]:px-1.5 has-data-[slot=attachment-content]:py-1"
    }.freeze

    ORIENTATIONS = {
      horizontal: "min-w-40 items-center",
      vertical: "w-24 flex-col has-data-[slot=attachment-content]:w-30"
    }.freeze

    def initialize(state: :done, size: :default, orientation: :horizontal, **attrs)
      @state = pick(state, STATES, :done)
      @size = pick(size, SIZES.keys, :default)
      @orientation = pick(orientation, ORIENTATIONS.keys, :horizontal)
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def pick(value, allowed, fallback)
      value = value.to_s.to_sym
      allowed.include?(value) ? value : fallback
    end

    def default_attrs
      {
        data: {slot: "attachment", state: @state, size: @size, orientation: @orientation},
        class: [
          "group/attachment relative flex w-fit max-w-full min-w-0 shrink-0 flex-wrap rounded-xl border",
          "bg-card text-card-foreground transition-colors focus-within:ring-1 focus-within:ring-ring/50",
          "has-[>a,>button]:hover:bg-muted/50 data-[state=error]:border-destructive/30 data-[state=idle]:border-dashed",
          SIZES[@size],
          ORIENTATIONS[@orientation]
        ]
      }
    end
  end
end
