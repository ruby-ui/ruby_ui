# frozen_string_literal: true

module RubyUI
  # The sheet panel: a native <dialog> opened with showModal(), so the browser
  # makes the page behind inert and handles Esc and initial focus. Styled after
  # shadcn's SheetContent (Base UI + vega).
  #
  # Side classes are plain utilities (not data-[side=…] variants) so a caller's
  # width or padding replaces them through tailwind_merge.
  class SheetContent < Base
    SIDE_CLASS = {
      top: "inset-x-0 top-0 bottom-auto h-auto w-full border-b " \
        "data-[state=open]:slide-in-from-top-10 data-[state=closed]:slide-out-to-top-10",
      right: "inset-y-0 right-0 left-auto h-full w-3/4 border-l sm:max-w-sm " \
        "data-[state=open]:slide-in-from-right-10 data-[state=closed]:slide-out-to-right-10",
      bottom: "inset-x-0 bottom-0 top-auto h-auto w-full border-t " \
        "data-[state=open]:slide-in-from-bottom-10 data-[state=closed]:slide-out-to-bottom-10",
      left: "inset-y-0 left-0 right-auto h-full w-3/4 border-r sm:max-w-sm " \
        "data-[state=open]:slide-in-from-left-10 data-[state=closed]:slide-out-to-left-10"
    }.freeze

    def initialize(side: :right, show_close_button: true, **attrs)
      @side = SIDE_CLASS.key?(side.to_s.to_sym) ? side.to_s.to_sym : :right
      @show_close_button = show_close_button
      super(**attrs)
    end

    def view_template
      dialog(**attrs) do
        yield if block_given?
        close_button if @show_close_button
      end
    end

    private

    def default_attrs
      {
        data: {
          slot: "sheet-content",
          side: @side,
          ruby_ui__sheet_target: "content",
          # Only for markup that still calls ruby-ui--sheet-content#close.
          controller: "ruby-ui--sheet-content",
          action: "pointerdown->ruby-ui--sheet#backdropPointerdown click->ruby-ui--sheet#backdropClick"
        },
        class: [
          # <dialog> UA styles: fixed inset 0, max width/height and fit-content size.
          "fixed z-50 m-0 max-h-none max-w-none flex-col gap-4 bg-popover bg-clip-padding text-sm text-popover-foreground shadow-lg outline-none open:flex not-open:hidden",
          "backdrop:bg-black/10 supports-backdrop-filter:backdrop:backdrop-blur-xs",
          "duration-200 ease-in-out data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:fill-mode-forwards motion-reduce:animate-none!",
          "backdrop:duration-150 data-[state=open]:backdrop:animate-in data-[state=open]:backdrop:fade-in-0 data-[state=closed]:backdrop:animate-out data-[state=closed]:backdrop:fade-out-0 data-[state=closed]:backdrop:fill-mode-forwards motion-reduce:backdrop:animate-none!",
          SIDE_CLASS.fetch(@side)
        ]
      }
    end

    # shadcn renders <Button variant="ghost" size="icon-sm">; the classes are
    # inlined because Button's own data-slot would be mixed into sheet-close.
    def close_button
      button(
        type: "button",
        class: "absolute top-4 end-4 size-8 shrink-0 rounded-[min(var(--radius-md),10px)] inline-flex items-center justify-center border border-transparent bg-clip-padding text-sm font-medium whitespace-nowrap outline-none select-none transition-all hover:bg-muted hover:text-foreground dark:hover:bg-muted/50 aria-expanded:bg-muted aria-expanded:text-foreground focus-visible:border-ring focus-visible:ring-3 focus-visible:ring-ring/50 active:not-aria-[haspopup]:translate-y-px disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg]:size-4",
        data: {slot: "sheet-close", action: "click->ruby-ui--sheet#dismiss"}
      ) do
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          viewbox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round",
          aria_hidden: "true"
        ) do |s|
          s.path(d: "M18 6 6 18")
          s.path(d: "m6 6 12 12")
        end
        span(class: "sr-only") { "Close" }
      end
    end
  end
end
