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

    # default..link mirror shadcn. success, warning and the palette colors are
    # RubyUI extras that follow the destructive pattern; their classes stay
    # literal so Tailwind can find them.
    VARIANTS = {
      default: "bg-primary text-primary-foreground [a]:hover:bg-primary/80",
      secondary: "bg-secondary text-secondary-foreground [a]:hover:bg-secondary/80",
      destructive: "bg-destructive/10 text-destructive dark:bg-destructive/20 [a]:hover:bg-destructive/20 " \
        "focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40",
      outline: "border-border text-foreground [a]:hover:bg-muted [a]:hover:text-muted-foreground",
      ghost: "hover:bg-muted hover:text-muted-foreground dark:hover:bg-muted/50",
      link: "text-primary underline-offset-4 hover:underline",
      success: "bg-success/10 text-success dark:bg-success/20 [a]:hover:bg-success/20",
      warning: "bg-warning/10 text-warning dark:bg-warning/20 [a]:hover:bg-warning/20",
      slate: "bg-slate-500/10 text-slate-500 dark:bg-slate-500/20 [a]:hover:bg-slate-500/20",
      gray: "bg-gray-500/10 text-gray-500 dark:bg-gray-500/20 [a]:hover:bg-gray-500/20",
      zinc: "bg-zinc-500/10 text-zinc-500 dark:bg-zinc-500/20 [a]:hover:bg-zinc-500/20",
      neutral: "bg-neutral-500/10 text-neutral-500 dark:bg-neutral-500/20 [a]:hover:bg-neutral-500/20",
      stone: "bg-stone-500/10 text-stone-500 dark:bg-stone-500/20 [a]:hover:bg-stone-500/20",
      red: "bg-red-500/10 text-red-500 dark:bg-red-500/20 [a]:hover:bg-red-500/20",
      orange: "bg-orange-500/10 text-orange-500 dark:bg-orange-500/20 [a]:hover:bg-orange-500/20",
      amber: "bg-amber-500/10 text-amber-500 dark:bg-amber-500/20 [a]:hover:bg-amber-500/20",
      yellow: "bg-yellow-500/10 text-yellow-500 dark:bg-yellow-500/20 [a]:hover:bg-yellow-500/20",
      lime: "bg-lime-500/10 text-lime-500 dark:bg-lime-500/20 [a]:hover:bg-lime-500/20",
      green: "bg-green-500/10 text-green-500 dark:bg-green-500/20 [a]:hover:bg-green-500/20",
      emerald: "bg-emerald-500/10 text-emerald-500 dark:bg-emerald-500/20 [a]:hover:bg-emerald-500/20",
      teal: "bg-teal-500/10 text-teal-500 dark:bg-teal-500/20 [a]:hover:bg-teal-500/20",
      cyan: "bg-cyan-500/10 text-cyan-500 dark:bg-cyan-500/20 [a]:hover:bg-cyan-500/20",
      sky: "bg-sky-500/10 text-sky-500 dark:bg-sky-500/20 [a]:hover:bg-sky-500/20",
      blue: "bg-blue-500/10 text-blue-500 dark:bg-blue-500/20 [a]:hover:bg-blue-500/20",
      indigo: "bg-indigo-500/10 text-indigo-500 dark:bg-indigo-500/20 [a]:hover:bg-indigo-500/20",
      violet: "bg-violet-500/10 text-violet-500 dark:bg-violet-500/20 [a]:hover:bg-violet-500/20",
      purple: "bg-purple-500/10 text-purple-500 dark:bg-purple-500/20 [a]:hover:bg-purple-500/20",
      fuchsia: "bg-fuchsia-500/10 text-fuchsia-500 dark:bg-fuchsia-500/20 [a]:hover:bg-fuchsia-500/20",
      pink: "bg-pink-500/10 text-pink-500 dark:bg-pink-500/20 [a]:hover:bg-pink-500/20",
      rose: "bg-rose-500/10 text-rose-500 dark:bg-rose-500/20 [a]:hover:bg-rose-500/20"
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
