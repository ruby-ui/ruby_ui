# frozen_string_literal: true

module RubyUI
  # An action. A div by default; href: makes it a link. variant: :destructive
  # paints it red, inset: lines it up with items that have an indicator,
  # disabled: keeps it focusable but never activated.
  # as: :div (kept for compatibility) renders a div even with href:.
  class DropdownMenuItem < Base
    ITEM = [
      "group/dropdown-menu-item relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none",
      "focus:bg-accent focus:text-accent-foreground not-data-[variant=destructive]:focus:**:text-accent-foreground",
      "data-disabled:pointer-events-none data-disabled:opacity-50 data-inset:pl-8",
      "data-[variant=destructive]:text-destructive data-[variant=destructive]:focus:bg-destructive/10",
      "dark:data-[variant=destructive]:focus:bg-destructive/20 data-[variant=destructive]:focus:text-destructive",
      "data-[variant=destructive]:*:[svg]:text-destructive",
      "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
    ].freeze

    def initialize(href: nil, as: nil, variant: :default, inset: false, disabled: false, **)
      @href = href
      @as = as&.to_sym
      @variant = (variant.to_sym == :destructive) ? :destructive : :default
      @inset = inset
      @disabled = disabled
      super(**)
    end

    def view_template(&)
      link? ? a(**attrs, &) : div(**attrs, &)
    end

    private

    def link?
      return false if @as == :div

      !@href.nil? || @as == :a
    end

    def default_attrs
      {
        href: (link? ? @href : nil),
        role: "menuitem",
        tabindex: "-1",
        aria: {disabled: (@disabled ? "true" : nil)},
        data: {
          slot: "dropdown-menu-item",
          variant: @variant,
          inset: @inset,
          disabled: @disabled,
          action: "click->ruby-ui--dropdown-menu#activate pointermove->ruby-ui--dropdown-menu#hover pointerleave->ruby-ui--dropdown-menu#leave"
        },
        class: ITEM
      }
    end
  end
end
