# frozen_string_literal: true

module RubyUI
  # shadcn's ToastClose: a ghost icon-sm Button in the toast row, with a
  # larger hit area (after:-inset-2).
  class ToastClose < Base
    def view_template
      render RubyUI::Button.new(variant: :ghost, size: :icon_sm, **button_attrs) do
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
          s.path(d: "M18 6 6 18")
          s.path(d: "m6 6 12 12")
        end
      end
    end

    private

    # slot! makes Button replace its own data-slot="button" instead of joining
    # it. Added after Base's mix, which would strip the bang.
    def button_attrs
      attrs.merge(data: attrs.fetch(:data, {}).merge(slot!: "toast-close"))
    end

    def default_attrs
      {
        aria_label: "Close toast",
        data: {action: "click->ruby-ui--toast#dismiss"},
        class: "relative shrink-0 text-muted-foreground after:absolute after:-inset-2 after:content-[''] hover:text-foreground"
      }
    end
  end
end
