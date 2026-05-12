# frozen_string_literal: true

module RubyUI
  class ToastIcon < Base
    def initialize(variant: nil, **attrs)
      @variant = variant&.to_sym
      super(**attrs)
    end

    def view_template
      return unless renderable?
      span(**attrs) do
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          width: "16",
          height: "16",
          viewbox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: "2",
          stroke_linecap: "round",
          stroke_linejoin: "round",
          class: "#{svg_classes} -ml-px"
        ) { |s| paths(s) }
      end
    end

    private

    def renderable?
      %i[success error warning info loading].include?(@variant)
    end

    def svg_classes
      base = "size-4"
      (@variant == :loading) ? "#{base} animate-spin" : base
    end

    def paths(s)
      case @variant
      when :success
        s.circle(cx: "12", cy: "12", r: "10")
        s.path(d: "m9 12 2 2 4-4")
      when :error
        s.path(d: "M2.586 16.726A2 2 0 0 1 2 15.312V8.688a2 2 0 0 1 .586-1.414l4.688-4.688A2 2 0 0 1 8.688 2h6.624a2 2 0 0 1 1.414.586l4.688 4.688A2 2 0 0 1 22 8.688v6.624a2 2 0 0 1-.586 1.414l-4.688 4.688a2 2 0 0 1-1.414.586H8.688a2 2 0 0 1-1.414-.586z")
        s.path(d: "m15 9-6 6")
        s.path(d: "m9 9 6 6")
      when :warning
        s.path(d: "m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3")
        s.path(d: "M12 9v4")
        s.path(d: "M12 17h.01")
      when :info
        s.circle(cx: "12", cy: "12", r: "10")
        s.path(d: "M12 16v-4")
        s.path(d: "M12 8h.01")
      when :loading
        s.path(d: "M21 12a9 9 0 1 1-6.219-8.56")
      end
    end

    def default_attrs
      {data: {slot: "icon"}, class: "shrink-0 inline-flex items-center justify-start relative size-4 -ml-[3px] mr-1 text-foreground"}
    end
  end
end
