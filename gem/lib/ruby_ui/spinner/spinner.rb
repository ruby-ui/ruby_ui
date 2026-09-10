# frozen_string_literal: true

module RubyUI
  class Spinner < Base
    # lucide loader-circle
    ICON_PATH = "M21 12a9 9 0 1 1-6.219-8.56"

    ICON_ATTRS = {
      xmlns: "http://www.w3.org/2000/svg",
      viewbox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round"
    }.freeze

    def initialize(label: "Loading", **attrs)
      @label = label
      super(**attrs)
    end

    def view_template
      svg(**ICON_ATTRS, **attrs) do |s|
        s.path(d: ICON_PATH)
      end
    end

    private

    def default_attrs
      {
        **announcement_attrs,
        data: {slot: "spinner"},
        class: "size-4 shrink-0 animate-spin"
      }
    end

    # A spinner inside a labelled control is decorative — the control announces busy.
    def announcement_attrs
      return {aria: {hidden: "true"}} if @label.to_s.strip.empty?

      {role: "status", aria: {label: @label}}
    end
  end
end
