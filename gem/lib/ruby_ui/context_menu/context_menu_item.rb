# frozen_string_literal: true

module RubyUI
  class ContextMenuItem < Base
    def initialize(href: "#", checked: false, shortcut: nil, disabled: false, **attrs)
      @href = href
      @checked = checked
      @shortcut = shortcut
      @disabled = disabled

      super(**attrs)
    end

    def view_template(&block)
      a(**attrs) do
        render_checkmark if @checked
        yield
        render_shortcut if @shortcut
      end
    end

    private

    def render_checkmark
      span(class: "absolute left-2 flex h-3.5 w-3.5 items-center justify-center") do
        span(data_state: "checked") do
          svg(
            width: "15",
            height: "15",
            viewbox: "0 0 15 15",
            fill: "none",
            xmlns: "http://www.w3.org/2000/svg",
            class: "h-4 w-4"
          ) do |s|
            s.path(
              d:
                    "M11.4669 3.72684C11.7558 3.91574 11.8369 4.30308 11.648 4.59198L7.39799 11.092C7.29783 11.2452 7.13556 11.3467 6.95402 11.3699C6.77247 11.3931 6.58989 11.3355 6.45446 11.2124L3.70446 8.71241C3.44905 8.48022 3.43023 8.08494 3.66242 7.82953C3.89461 7.57412 4.28989 7.55529 4.5453 7.78749L6.75292 9.79441L10.6018 3.90792C10.7907 3.61902 11.178 3.53795 11.4669 3.72684Z",
              fill: "currentColor",
              fill_rule: "evenodd",
              clip_rule: "evenodd"
            )
          end
        end
      end
    end

    def render_shortcut
      span(class: "ml-auto text-xs tracking-widest text-muted-foreground") { @shortcut }
    end

    def default_attrs
      {
        href: @href,
        role: "menuitem",
        class:
              "relative flex cursor-pointer select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground aria-selected:bg-accent aria-selected:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50 pl-8",
        tabindex: "-1",
        data_orientation: "vertical",
        data_action: "click->ruby-ui--context-menu#close",
        data_ruby_ui__context_menu_target: "menuItem",
        data_disabled: @disabled,
        disabled: @disabled
      }
    end
  end
end
