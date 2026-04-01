# frozen_string_literal: true

module RubyUI
  class Badge < Base
    SIZES = {
      sm: 'px-1.5 py-0.5 text-xs',
      md: 'px-2 py-1 text-xs',
      lg: 'px-3 py-1 text-sm'
    }.freeze

    COLORS = {
      primary: 'text-primary bg-primary/5 ring-primary/20',
      secondary: 'text-secondary bg-secondary/10 ring-secondary/20',
      outline: 'text-foreground bg-background ring-border',
      destructive: 'text-destructive bg-destructive/10 ring-destructive/20',
      success: 'text-success bg-success/10 ring-success/20',
      warning: 'text-warning bg-warning/10 ring-warning/20',
      slate: 'text-slate-500 bg-slate-500/10 ring-slate-500/20',
      gray: 'text-gray-500 bg-gray-500/10 ring-gray-500/20',
      zinc: 'text-zinc-500 bg-zinc-500/10 ring-zinc-500/20',
      neutral: 'text-neutral-500 bg-neutral-500/10 ring-neutral-500/20',
      stone: 'text-stone-500 bg-stone-500/10 ring-stone-500/20',
      red: 'text-red-500 bg-red-500/10 ring-red-500/20',
      orange: 'text-orange-500 bg-orange-500/10 ring-orange-500/20',
      amber: 'text-amber-500 bg-amber-500/10 ring-amber-500/20',
      yellow: 'text-yellow-500 bg-yellow-500/10 ring-yellow-500/20',
      lime: 'text-lime-500 bg-lime-500/10 ring-lime-500/20',
      green: 'text-green-500 bg-green-500/10 ring-green-500/20',
      emerald: 'text-emerald-500 bg-emerald-500/10 ring-emerald-500/20',
      teal: 'text-teal-500 bg-teal-500/10 ring-teal-500/20',
      cyan: 'text-cyan-500 bg-cyan-500/10 ring-cyan-500/20',
      sky: 'text-sky-500 bg-sky-500/10 ring-sky-500/20',
      blue: 'text-blue-500 bg-blue-500/10 ring-blue-500/20',
      indigo: 'text-indigo-500 bg-indigo-500/10 ring-indigo-500/20',
      violet: 'text-violet-500 bg-violet-500/10 ring-violet-500/20',
      purple: 'text-purple-500 bg-purple-500/10 ring-purple-500/20',
      fuchsia: 'text-fuchsia-500 bg-fuchsia-500/10 ring-fuchsia-500/20',
      pink: 'text-pink-500 bg-pink-500/10 ring-pink-500/20',
      rose: 'text-rose-500 bg-rose-500/10 ring-rose-500/20'
    }.freeze

    def initialize(variant: :primary, size: :md, **args)
      @variant = variant
      @size = size
      super(**args)
    end

    def view_template(&)
      span(**attrs, &)
    end

    private

    def default_attrs
      {
        class: ['inline-flex items-center rounded-md font-medium ring-1 ring-inset', SIZES[@size], COLORS[@variant]]
      }
    end
  end
end
