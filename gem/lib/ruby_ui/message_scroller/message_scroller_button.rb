# frozen_string_literal: true

module RubyUI
  class MessageScrollerButton < Base
    def initialize(direction: :end, **attrs)
      @direction = direction
      super(**attrs)
    end

    def view_template(&)
      button(**attrs) do
        if block_given?
          yield
        else
          default_icon
          span(class: "sr-only") { (@direction == :start) ? "Scroll to start" : "Scroll to end" }
        end
      end
    end

    private

    def default_attrs
      {
        type: "button",
        tabindex: "-1",
        data: {
          slot: "message-scroller-button",
          direction: @direction,
          active: "false",
          ruby_ui__message_scroller_target: "button",
          action: "click->ruby-ui--message-scroller#jump"
        },
        class: "absolute left-1/2 z-10 -translate-x-1/2 inline-flex size-8 items-center justify-center rounded-full border border-border bg-background text-foreground shadow-sm transition-[translate,scale,opacity] duration-200 hover:bg-muted hover:text-foreground data-[active=false]:pointer-events-none data-[active=false]:scale-95 data-[active=false]:opacity-0 data-[active=true]:scale-100 data-[active=true]:opacity-100 data-[direction=end]:bottom-4 data-[direction=end]:data-[active=false]:translate-y-full data-[direction=start]:top-4 data-[direction=start]:data-[active=false]:-translate-y-full data-[direction=start]:[&_svg]:rotate-180"
      }
    end

    def default_icon
      svg(
        xmlns: "http://www.w3.org/2000/svg",
        width: "24",
        height: "24",
        viewbox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke_width: "2",
        stroke_linecap: "round",
        stroke_linejoin: "round",
        class: "size-4"
      ) do |s|
        s.path(d: "M12 5v14")
        s.path(d: "m19 12-7 7-7-7")
      end
    end
  end
end
