# frozen_string_literal: true

module RubyUI
  # An action. A div by default; href: makes it a link. variant: :destructive
  # paints it red, inset: lines it up with items that have an indicator.
  # shortcut: renders a ContextMenuShortcut; checked: true (kept for
  # compatibility) renders a ContextMenuCheckboxItem instead, while
  # checked: false stays a plain item, as before.
  class ContextMenuItem < Base
    ITEM = [
      "group/context-menu-item relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none",
      "focus:bg-accent focus:text-accent-foreground focus:*:[svg]:text-accent-foreground",
      "data-disabled:pointer-events-none data-disabled:opacity-50 data-inset:pl-8",
      "data-[variant=destructive]:text-destructive data-[variant=destructive]:focus:bg-destructive/10",
      "dark:data-[variant=destructive]:focus:bg-destructive/20 data-[variant=destructive]:focus:text-destructive",
      "data-[variant=destructive]:*:[svg]:text-destructive",
      "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
    ].freeze

    def initialize(href: nil, variant: :default, inset: false, disabled: false, shortcut: nil, checked: false, **attrs)
      @href = href
      @variant = (variant.to_sym == :destructive) ? :destructive : :default
      @inset = inset
      @disabled = disabled
      @shortcut = shortcut
      @checked = checked
      @user_attrs = attrs
      super(**attrs)
    end

    def view_template(&block)
      if @checked == true
        return render ContextMenuCheckboxItem.new(checked: @checked, inset: @inset, disabled: @disabled, shortcut: @shortcut, **@user_attrs), &block
      end

      tag = @href ? :a : :div
      send(tag, **attrs) do
        yield if block
        render ContextMenuShortcut.new { @shortcut } if @shortcut
      end
    end

    private

    def default_attrs
      {
        href: @href,
        role: "menuitem",
        tabindex: "-1",
        aria: {disabled: (@disabled ? "true" : nil)},
        data: {
          slot: "context-menu-item",
          variant: @variant,
          inset: @inset,
          disabled: @disabled,
          action: "click->ruby-ui--context-menu#activate pointermove->ruby-ui--context-menu#hover pointerleave->ruby-ui--context-menu#leave"
        },
        class: ITEM
      }
    end
  end
end
