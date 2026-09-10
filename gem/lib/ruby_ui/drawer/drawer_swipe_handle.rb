# frozen_string_literal: true

module RubyUI
  class DrawerSwipeHandle < Base
    DRAG_ACTIONS = [
      "pointerdown->ruby-ui--drawer-content#startDrag",
      "pointermove->ruby-ui--drawer-content#drag",
      "pointerup->ruby-ui--drawer-content#endDrag",
      "pointercancel->ruby-ui--drawer-content#endDrag"
    ].join(" ").freeze

    def view_template
      div(**attrs)
    end

    private

    # The bar is 6px tall; ::after stretches the grab strip across the panel and down over the header.
    def default_attrs
      {
        class: "relative z-10 mx-auto mt-3 h-1.5 w-12 shrink-0 cursor-grab touch-none rounded-full bg-muted-foreground/40 active:cursor-grabbing after:absolute after:-inset-x-[50vw] after:-top-3 after:-bottom-6 after:content-['']",
        aria: {hidden: "true"},
        data: {action: DRAG_ACTIONS}
      }
    end
  end
end
