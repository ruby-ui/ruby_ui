# frozen_string_literal: true

module RubyUI
  class Separator < Base
    ORIENTATIONS = %i[horizontal vertical].freeze

    # decorative: true renders role="none" for a purely visual line (hidden
    # from assistive tech). shadcn (Base UI) has no such prop: it always
    # renders a semantic separator, which is the default here too.
    def initialize(as: :div, orientation: :horizontal, decorative: false, **attrs)
      raise ArgumentError, "Invalid orientation: #{orientation}" unless ORIENTATIONS.include?(orientation.to_sym)

      @as = as
      @orientation = orientation.to_sym
      @decorative = decorative
      super(**attrs)
    end

    def view_template(&)
      tag(@as, **attrs, &)
    end

    private

    def default_attrs
      {
        role: role,
        aria: {orientation: aria_orientation},
        data: {slot: "separator", orientation: @orientation},
        class: [
          "shrink-0 bg-border",
          orientation_classes,
          hr_classes
        ]
      }
    end

    # <hr> already has the separator role: an explicit one would be redundant.
    def role
      return "none" if @decorative

      "separator" unless hr?
    end

    # The separator role's implicit aria-orientation is horizontal, so <hr>
    # only needs it when vertical. A decorative line has no orientation.
    def aria_orientation
      return if @decorative
      return if hr? && @orientation == :horizontal

      @orientation.to_s
    end

    def hr?
      @as.to_sym == :hr
    end

    # Tailwind's preflight sets hr { height: 0; border-top-width: 1px }: drop the
    # border (h-px already draws the line) and, when vertical, the fixed height,
    # or self-stretch can't stretch it.
    def hr_classes
      return unless hr?
      return "border-0 h-auto" if @orientation == :vertical

      "border-0"
    end

    # shadcn keys these on data-orientation via its data-horizontal:/data-vertical:
    # custom variants, which RubyUI's Tailwind setup doesn't define; the classes are
    # picked here instead. self-stretch (not h-full) fills a flex row with no fixed height.
    def orientation_classes
      return "h-px w-full" if @orientation == :horizontal

      "w-px self-stretch"
    end
  end
end
