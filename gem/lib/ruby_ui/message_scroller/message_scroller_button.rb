# frozen_string_literal: true

module RubyUI
  # Jumps to the end (or start) of the transcript. Styled as a RubyUI Button
  # (shadcn renders <Button variant="secondary" size="icon-sm">); variant: and
  # size: take the same values as Button. Inactive while the reader is
  # already at that edge: hidden, inert and out of the tab order.
  #
  # behavior: :smooth (default) or :auto (jump at once).
  # shadcn's render prop has no counterpart; pass a block for custom content.
  class MessageScrollerButton < Base
    CLASSES = [
      "absolute inset-s-1/2 -translate-x-1/2 border-border bg-background text-foreground",
      "transition-[translate,scale,opacity] duration-200 hover:bg-muted hover:text-foreground",
      "data-[active=false]:pointer-events-none data-[active=false]:scale-95 data-[active=false]:opacity-0",
      "data-[active=false]:duration-400 data-[active=false]:ease-[cubic-bezier(0.7,0,0.84,0)]",
      "data-[active=true]:translate-y-0 data-[active=true]:scale-100 data-[active=true]:opacity-100",
      "data-[active=true]:ease-[cubic-bezier(0.23,1,0.32,1)]",
      "data-[direction=end]:bottom-4 data-[direction=end]:data-[active=false]:translate-y-full",
      "data-[direction=start]:top-4 data-[direction=start]:data-[active=false]:-translate-y-full",
      "rtl:translate-x-1/2 data-[direction=start]:[&_svg]:rotate-180"
    ].freeze

    def initialize(direction: :end, behavior: :smooth, variant: :secondary, size: :icon_sm, **attrs)
      @direction = direction.to_s
      @behavior = behavior.to_s
      @variant = variant
      @size = size
      super(**attrs)
    end

    def view_template
      button(**attrs) do
        if block_given?
          yield
        else
          default_icon
          span(class: "sr-only") { (@direction == "start") ? "Scroll to start" : "Scroll to end" }
        end
      end
    end

    private

    def default_attrs
      {
        type: "button",
        tabindex: "-1",
        # Inactive until the controller measures the viewport.
        inert: true,
        data: {
          slot: "message-scroller-button",
          direction: @direction,
          behavior: @behavior,
          variant: @variant.to_s.tr("_", "-"),
          size: @size.to_s.tr("_", "-"),
          active: "false",
          ruby_ui__message_scroller_target: "button",
          ruby_ui__message_scroller_direction_param: @direction,
          ruby_ui__message_scroller_behavior_param: @behavior,
          action: "click->ruby-ui--message-scroller#jump"
        },
        class: [Button.new(variant: @variant, size: @size).attrs[:class], *CLASSES]
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
        aria_hidden: "true"
      ) do |s|
        s.path(d: "M12 5v14")
        s.path(d: "m19 12-7 7-7-7")
      end
    end
  end
end
