# frozen_string_literal: true

module RubyUI
  class DrawerContent < Base
    # snap_points: how far up the panel comes at each rest position, in shadcn's units; initial: index it opens at.
    # dismissible: false ignores the scrim click, Escape and a swipe below the lowest snap point.
    # initial_focus: false focuses the panel instead of the first field, so a form does not raise the keyboard on open.
    def initialize(snap_points: [0.6, 0.92], initial: 0, modal: true, dismissible: true, handle: true, initial_focus: true, **attrs)
      @snap_points = snap_points
      @initial = initial
      @modal = modal
      @dismissible = dismissible
      @handle = handle
      @initial_focus = initial_focus
      super(**attrs)
    end

    def view_template(&block)
      template(data: {ruby_ui__drawer_target: "content"}) do
        dialog(**dialog_attrs) do
          backdrop if @modal
          scroller do
            @snap_points.each { |point| snap_marker(point) }
            # Full-screen spacer: makes the scroll range, and scrollTop 0 the dismissed rest position.
            div(class: "h-full snap-start")
            div(**attrs) do
              RubyUI.DrawerSwipeHandle() if @handle
              block&.call
            end
          end
        end
      end
    end

    private

    # The panel is full-height; only the band above the fold (--drawer-band, tracked by the controller) is laid out.
    # The dialog's focusing steps prefer an autofocus element, so a focusable panel keeps focus off the fields.
    def default_attrs
      {
        class: "group/drawer relative flex h-full flex-col overflow-clip rounded-t-lg bg-background text-foreground shadow-[0_-8px_30px_rgb(0_0_0/0.12)] snap-start pointer-events-auto after:flex-none after:h-[calc(100%_-_var(--drawer-band))] after:content-['']",
        tabindex: ("-1" unless @initial_focus),
        autofocus: (true unless @initial_focus),
        data: {
          ruby_ui__drawer_content_target: "panel",
          # Style hooks, as in shadcn: the controller adds data-expanded and data-swiping.
          snap_points: (true if @snap_points.any?)
        }
      }
    end

    # Full-screen transparent <dialog> with pointer events off (the non-modal page stays reachable); backdrop and panel opt back in.
    def dialog_attrs
      {
        class: "fixed inset-0 z-50 m-0 h-full w-full max-h-none max-w-none border-0 bg-transparent p-0 pointer-events-none backdrop:bg-transparent",
        style: "--drawer-band: #{open_length}",
        data: {
          controller: "ruby-ui--drawer-content",
          turbo_temporary: true,
          ruby_ui__drawer_content_initial_value: @initial,
          ruby_ui__drawer_content_modal_value: @modal.to_s,
          ruby_ui__drawer_content_dismissible_value: @dismissible.to_s
        }
      }
    end

    # Out of range opens at the first snap point, as the controller does; without any, the panel is full height.
    def open_length
      point = @snap_points[@initial.clamp(0..)] || @snap_points.first
      point ? css_length(point) : "100%"
    end

    # shadcn's units: up to 1 is a fraction of the viewport, above 1 is pixels, and a string passes through ("24rem").
    def css_length(point)
      return point if point.is_a?(String)

      (point > 1) ? "#{css_number(point)}px" : "#{css_number(point * 100)}%"
    end

    # 0.6 * 100 is 60.00000000000001 in binary floating point, and CSS should read 60%.
    # Kernel#format would be the obvious tool, but phlex-rails gives every component its own zero-argument #format.
    def css_number(number)
      rounded = number.round(6)
      ((rounded % 1) == 0) ? rounded.to_i : rounded
    end

    def backdrop
      div(
        class: "fixed inset-0 z-50 pointer-events-auto bg-background/80 backdrop-blur-sm transition-none duration-200 data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:fill-mode-forwards",
        data: {
          state: "open",
          action: "click->ruby-ui--drawer-content#dismiss",
          ruby_ui__drawer_content_target: "backdrop"
        }
      )
    end

    # Vertical snap scroller: scrolling up reveals the panel and the browser snaps to the markers.
    def scroller(&)
      div(
        class: "fixed inset-0 z-50 overflow-y-scroll overscroll-y-none snap-y snap-mandatory pointer-events-none [scrollbar-width:none] [&::-webkit-scrollbar]:hidden",
        data: {ruby_ui__drawer_content_target: "scroller"},
        &
      )
    end

    # Sentinel out of the flow: its ::before is the snap target, and its offsetTop is the scroll position the controller animates to.
    def snap_marker(point)
      div(
        class: "relative -mb-px h-px before:absolute before:inset-x-0 before:top-0 before:h-px before:snap-start before:content-['']",
        style: "top: #{css_length(point)}",
        data: {ruby_ui__drawer_content_target: "snap"}
      )
    end
  end
end
