# frozen_string_literal: true

module RubyUI
  # A button, styled after shadcn's Button (Base UI + vega). Renders a
  # <button>, or an <a> when given href: (shadcn's render={<a />}).
  #
  # icon: true makes a square icon button of the given size (shadcn's
  # size="icon", "icon-sm"…); size: :icon, :icon_sm… work too. An icon marked
  # data-icon="inline-start" or "inline-end" gets tighter padding on its side.
  #
  # focusable_when_disabled: true (with disabled: true) keeps the button in the
  # tab order: it renders aria-disabled instead of disabled and blocks clicks.
  class Button < Base
    BASE = [
      "group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap",
      "rounded-md border border-transparent bg-clip-padding text-sm font-medium",
      "transition-all outline-none select-none active:not-aria-[haspopup]:translate-y-px",
      "focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50",
      "aria-invalid:border-destructive aria-invalid:ring-3 aria-invalid:ring-destructive/20",
      "dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40",
      "disabled:pointer-events-none disabled:opacity-50",
      "aria-disabled:pointer-events-none aria-disabled:opacity-50 aria-disabled:cursor-not-allowed",
      "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
    ].freeze

    # :primary is shadcn's default variant.
    VARIANTS = {
      primary: "bg-primary text-primary-foreground hover:bg-primary/80",
      outline: "border-border bg-background shadow-xs hover:bg-muted hover:text-foreground " \
        "aria-expanded:bg-muted aria-expanded:text-foreground " \
        "dark:border-input dark:bg-input/30 dark:hover:bg-input/50",
      secondary: "bg-secondary text-secondary-foreground " \
        "hover:bg-[color-mix(in_oklch,var(--secondary),var(--foreground)_5%)] " \
        "aria-expanded:bg-secondary aria-expanded:text-secondary-foreground",
      ghost: "hover:bg-muted hover:text-foreground dark:hover:bg-muted/50 " \
        "aria-expanded:bg-muted aria-expanded:text-foreground",
      destructive: "bg-destructive/10 text-destructive hover:bg-destructive/20 " \
        "focus-visible:border-destructive/40 focus-visible:ring-destructive/20 " \
        "dark:bg-destructive/20 dark:hover:bg-destructive/30 dark:focus-visible:ring-destructive/40",
      link: "text-primary underline-offset-4 hover:underline"
    }.freeze

    # :md is shadcn's default size; :xl is a RubyUI extra.
    SIZES = {
      xs: "h-6 gap-1 rounded-[min(var(--radius-md),8px)] px-2 text-xs in-data-[slot=button-group]:rounded-md " \
        "has-data-[icon=inline-end]:pr-1.5 has-data-[icon=inline-start]:pl-1.5 [&_svg:not([class*='size-'])]:size-3",
      sm: "h-8 gap-1 rounded-[min(var(--radius-md),10px)] px-2.5 in-data-[slot=button-group]:rounded-md " \
        "has-data-[icon=inline-end]:pr-1.5 has-data-[icon=inline-start]:pl-1.5",
      md: "h-9 gap-1.5 px-2.5 in-data-[slot=button-group]:rounded-md " \
        "has-data-[icon=inline-end]:pr-2 has-data-[icon=inline-start]:pl-2",
      lg: "h-10 gap-1.5 px-2.5 has-data-[icon=inline-end]:pr-2 has-data-[icon=inline-start]:pl-2",
      xl: "h-12 gap-2 px-4 has-data-[icon=inline-end]:pr-3 has-data-[icon=inline-start]:pl-3"
    }.freeze

    # Square icon buttons. h-/w- instead of size-* so callers can still
    # override one side with h-8 or w-8.
    ICON_SIZES = {
      xs: "h-6 w-6 rounded-[min(var(--radius-md),8px)] in-data-[slot=button-group]:rounded-md " \
        "[&_svg:not([class*='size-'])]:size-3",
      sm: "h-8 w-8 rounded-[min(var(--radius-md),10px)] in-data-[slot=button-group]:rounded-md",
      md: "h-9 w-9",
      lg: "h-10 w-10",
      xl: "h-12 w-12"
    }.freeze

    VARIANT_ALIASES = {default: :primary}.freeze
    # shadcn's size names: default, icon, icon-xs, icon-sm, icon-lg.
    SIZE_ALIASES = {default: :md, icon: :md, icon_xs: :xs, icon_sm: :sm, icon_md: :md, icon_lg: :lg, icon_xl: :xl}.freeze

    def initialize(type: :button, variant: :primary, size: :md, icon: false, href: nil,
      disabled: false, focusable_when_disabled: false, **attrs)
      @type = type
      @variant = variant.to_s.to_sym
      @variant = VARIANT_ALIASES.fetch(@variant, @variant)
      @variant = :primary unless VARIANTS.key?(@variant)
      size = size.to_s.tr("-", "_").to_sym
      @icon = icon || size.start_with?("icon")
      @size = SIZE_ALIASES.fetch(size, size)
      @size = :md unless SIZES.key?(@size)
      @href = href
      @disabled = disabled
      @focusable_when_disabled = focusable_when_disabled
      super(**attrs)
      # mix concatenates strings, so a caller's own aria: {disabled: "true"}
      # would turn ours into "true true", which the controller doesn't read as
      # disabled.
      @attrs[:aria][:disabled] = "true" if aria_disabled?
    end

    def view_template(&)
      if @href
        a(**attrs, &)
      else
        button(**attrs, &)
      end
    end

    private

    def default_attrs
      data = {slot: "button"}
      attrs = {class: [BASE, (@icon ? ICON_SIZES : SIZES).fetch(@size), VARIANTS.fetch(@variant)], data: data}

      if @href
        # A disabled link has no href: it can't be followed or focused.
        attrs[:href] = @href unless @disabled
      else
        attrs[:type] = @type
      end

      if @disabled
        data[:disabled] = true
        if aria_disabled?
          attrs[:aria] = {disabled: "true"}
          # A link without href has no role of its own; keep it a link.
          attrs[:role] = "link" if @href
          if @focusable_when_disabled
            attrs[:tabindex] = 0 if @href
            data[:controller] = "ruby-ui--button"
          end
        else
          attrs[:disabled] = true
        end
      end

      attrs
    end

    # Disabled through aria-disabled instead of the disabled attribute: links
    # have no disabled attribute, and focusable_when_disabled must keep focus.
    def aria_disabled?
      @disabled && (@href || @focusable_when_disabled)
    end
  end
end
