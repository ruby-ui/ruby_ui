# frozen_string_literal: true

module RubyUI
  # Base UI's Tabs.Tab (role=tab). as: :a renders a link for tabs that
  # navigate. disabled: true keeps the tab reachable with the arrow keys
  # (aria-disabled, as Base UI does) but it can't be activated.
  class TabsTrigger < Base
    def initialize(value:, as: :button, disabled: false, **attrs)
      @value = value
      @as = as
      @disabled = disabled
      super(**attrs)
    end

    def view_template(&)
      if @as == :a
        a(**attrs, &)
      else
        button(**attrs, &)
      end
    end

    private

    def default_attrs
      base = {
        role: "tab",
        aria: {selected: "false", disabled: (@disabled ? "true" : nil)},
        data: {
          slot: "tabs-trigger",
          disabled: (@disabled ? true : nil),
          ruby_ui__tabs_target: "trigger",
          action: "click->ruby-ui--tabs#show",
          value: @value
        },
        class: [
          "relative inline-flex h-[calc(100%-1px)] flex-1 items-center justify-center gap-1.5 whitespace-nowrap rounded-md border border-transparent px-2 py-1 text-sm font-medium text-foreground/60 transition-all",
          "hover:text-foreground dark:text-muted-foreground dark:hover:text-foreground",
          "focus-visible:border-ring focus-visible:outline-1 focus-visible:outline-ring focus-visible:ring-[3px] focus-visible:ring-ring/50",
          "disabled:pointer-events-none disabled:opacity-50 aria-disabled:pointer-events-none aria-disabled:opacity-50",
          "group-data-[orientation=vertical]/tabs:w-full group-data-[orientation=vertical]/tabs:justify-start",
          "data-active:bg-background data-active:text-foreground dark:data-active:border-input dark:data-active:bg-input/30 dark:data-active:text-foreground",
          "group-data-[variant=default]/tabs-list:data-active:shadow-sm group-data-[variant=line]/tabs-list:data-active:shadow-none",
          "group-data-[variant=line]/tabs-list:bg-transparent group-data-[variant=line]/tabs-list:data-active:bg-transparent dark:group-data-[variant=line]/tabs-list:data-active:border-transparent dark:group-data-[variant=line]/tabs-list:data-active:bg-transparent",
          # The line variant's indicator.
          "after:absolute after:bg-foreground after:opacity-0 after:transition-opacity group-data-[variant=line]/tabs-list:data-active:after:opacity-100",
          "group-data-[orientation=horizontal]/tabs:after:inset-x-0 group-data-[orientation=horizontal]/tabs:after:bottom-[-5px] group-data-[orientation=horizontal]/tabs:after:h-0.5",
          "group-data-[orientation=vertical]/tabs:after:inset-y-0 group-data-[orientation=vertical]/tabs:after:-right-1 group-data-[orientation=vertical]/tabs:after:w-0.5",
          "has-data-[icon=inline-end]:pr-1.5 has-data-[icon=inline-start]:pl-1.5",
          "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
        ]
      }
      base[:type] = :button unless @as == :a
      base
    end
  end
end
