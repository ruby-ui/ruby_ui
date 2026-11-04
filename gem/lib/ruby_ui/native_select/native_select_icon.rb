# frozen_string_literal: true

module RubyUI
  class NativeSelectIcon < Base
    # Renders the chevron <svg> itself, as shadcn does. A block replaces the
    # chevron; its content is wrapped in a <span> that takes the same classes.
    def view_template(&block)
      if block
        span(**attrs, &block)
      else
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          viewBox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round",
          **attrs
        ) do |s|
          s.path(d: "m6 9 6 6 6-6")
        end
      end
    end

    private

    def default_attrs
      {
        aria: {hidden: "true"},
        data: {slot: "native-select-icon"},
        class: "text-muted-foreground pointer-events-none absolute top-1/2 right-2.5 size-4 -translate-y-1/2 select-none"
      }
    end
  end
end
