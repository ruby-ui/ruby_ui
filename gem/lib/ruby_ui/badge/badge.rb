# frozen_string_literal: true

module RubyUI
  # A small label. Renders a <span>, or an <a> when given href:, which turns on
  # the variants' hover styles and the focus ring, like shadcn's
  # <Badge render={<a />}>. An icon marked data-icon="inline-start" or
  # "inline-end" gets tighter padding on its side.
  class Badge < Base
    BASE = [
      "group/badge inline-flex h-5 w-fit shrink-0 items-center justify-center gap-1 overflow-hidden whitespace-nowrap",
      "rounded-4xl border border-transparent px-2 py-0.5 text-xs font-medium transition-all",
      "has-data-[icon=inline-end]:pr-1.5 has-data-[icon=inline-start]:pl-1.5",
      "[&>svg]:pointer-events-none [&>svg]:size-3!",
      "focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50",
      "aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40"
    ].freeze

    # :md is shadcn's only size; :sm and :lg are RubyUI extras.
    SIZES = {
      sm: "h-4 px-1.5",
      md: "",
      lg: "h-6 px-2.5 text-sm"
    }.freeze

    # Variants mirror shadcn; pass class: for any other color.
    VARIANTS = {
      default: "bg-primary text-primary-foreground [a]:hover:bg-primary/80",
      secondary: "bg-secondary text-secondary-foreground [a]:hover:bg-secondary/80",
      destructive: "bg-destructive/10 text-destructive dark:bg-destructive/20 [a]:hover:bg-destructive/20 " \
        "focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40",
      outline: "border-border text-foreground [a]:hover:bg-muted [a]:hover:text-muted-foreground",
      ghost: "hover:bg-muted hover:text-muted-foreground dark:hover:bg-muted/50",
      link: "text-primary underline-offset-4 hover:underline"
    }.freeze

    # Older name of :default, kept so variant: :primary keeps working.
    ALIASES = {primary: :default}.freeze

    def initialize(variant: :default, size: :md, href: nil, **attrs)
      @variant = variant.to_s.to_sym
      @variant = ALIASES.fetch(@variant, @variant)
      @variant = :default unless VARIANTS.key?(@variant) # nil or unknown: default look
      @size = SIZES.key?(size.to_s.to_sym) ? size.to_s.to_sym : :md
      @href = href
      super(**attrs)
    end

    def view_template(&)
      if @href
        a(href: @href, **attrs, &)
      else
        span(**attrs, &)
      end
    end

    private

    def default_attrs
      {
        data: {slot: "badge", variant: @variant},
        class: [BASE, SIZES.fetch(@size), VARIANTS.fetch(@variant)]
      }
    end
  end
end
