# frozen_string_literal: true

module RubyUI
  # Copies value: (or, without it, the block's code) to the clipboard. After
  # copying, the icon turns into a check and the label into copied_label for
  # two seconds; a polite live region announces it. A failed copy shows
  # nothing, as in shadcn. Needs a Codeblock around it (its Stimulus
  # controller lives on the root).
  class CodeblockCopyButton < Base
    # error_label: is deprecated and ignored: a failed copy shows nothing.
    def initialize(value: nil, label: "Copy", copied_label: "Copied", error_label: nil,
      variant: :ghost, size: :xs, **attrs)
      unless error_label.nil?
        Warning.warn("RubyUI::CodeblockCopyButton: `error_label:` is deprecated and ignored " \
          "(a failed copy shows nothing, as in shadcn)\n", category: :deprecated)
      end
      @value = value
      @label = label
      @copied_label = copied_label
      @variant = variant
      @size = size
      super(**attrs)
    end

    def view_template
      button = Button.new(variant: @variant, size: @size, icon: true, **attrs)
      # mix joins strings, so the Button's own slot would read "button code-block-copy-button".
      button.attrs[:data][:slot] = "code-block-copy-button"
      render button do
        copy_icon
        check_icon
      end
      span(aria_live: "polite", class: "sr-only", data: {slot: "code-block-copy-status"})
    end

    private

    def default_attrs
      data = {
        slot: "code-block-copy-button",
        action: "ruby-ui--codeblock#copy",
        label: @label,
        copied_label: @copied_label
      }
      data[:value] = @value unless @value.nil?
      {aria: {label: @label}, data: data}
    end

    # lucide copy and check, as in shadcn; the button's data-copied picks one.
    def copy_icon
      icon(class: "group-data-copied/button:hidden") do |s|
        s.rect(width: "14", height: "14", x: "8", y: "8", rx: "2", ry: "2")
        s.path(d: "M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2")
      end
    end

    def check_icon
      icon(class: "hidden group-data-copied/button:block") do |s|
        s.path(d: "M20 6 9 17l-5-5")
      end
    end

    def icon(**, &)
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
        aria_hidden: "true",
        **, &
      )
    end
  end
end
