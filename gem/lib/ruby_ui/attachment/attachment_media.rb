# frozen_string_literal: true

module RubyUI
  # The square thumbnail of an Attachment: an icon (variant: :icon) or an
  # <img> that fills it (variant: :image). The image is dimmed until the
  # attachment is :idle or :done.
  class AttachmentMedia < Base
    VARIANTS = {
      icon: "",
      image: "opacity-60 group-data-[state=idle]/attachment:opacity-100 group-data-[state=done]/attachment:opacity-100 " \
        "*:[img]:aspect-square *:[img]:w-full *:[img]:object-cover"
    }.freeze

    def initialize(variant: :icon, **attrs)
      @variant = variant.to_s.to_sym
      @variant = :icon unless VARIANTS.key?(@variant)
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "attachment-media", variant: @variant},
        class: [
          "relative flex aspect-square w-10 shrink-0 items-center justify-center overflow-hidden rounded-lg bg-muted text-foreground",
          "group-data-[state=error]/attachment:bg-destructive/10 group-data-[state=error]/attachment:text-destructive",
          "group-data-[size=sm]/attachment:w-8 group-data-[size=xs]/attachment:w-7 group-data-[size=xs]/attachment:rounded-md",
          "group-data-[orientation=vertical]/attachment:w-full",
          "[&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4",
          "group-data-[size=xs]/attachment:[&_svg:not([class*='size-'])]:size-3.5",
          "group-data-[orientation=vertical]/attachment:[&_svg:not([class*='size-'])]:size-6",
          "group-data-[orientation=vertical]/attachment:*:data-[slot=spinner]:size-6!",
          VARIANTS[@variant]
        ]
      }
    end
  end
end
