# frozen_string_literal: true

module RubyUI
  # Buttons for the block. Inside a CodeblockHeader they sit at its end; as a
  # direct child of Codeblock they float in the top-right corner and show on
  # hover or focus (always on touch screens).
  class CodeblockActions < Base
    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        data: {slot: "code-block-actions"},
        class: [
          "ms-auto -me-1.5 -my-1 flex shrink-0 items-center gap-1",
          "[[data-slot=code-block]>&]:absolute [[data-slot=code-block]>&]:end-3 [[data-slot=code-block]>&]:top-3 [[data-slot=code-block]>&]:z-10 [[data-slot=code-block]>&]:m-0",
          "group-data-[size=sm]/code-block:[[data-slot=code-block]>&]:end-2 group-data-[size=sm]/code-block:[[data-slot=code-block]>&]:top-2",
          "[[data-slot=code-block]>&]:opacity-0 [[data-slot=code-block]>&]:transition-opacity",
          "[[data-slot=code-block]>&]:group-focus-within/code-block:opacity-100 [[data-slot=code-block]>&]:group-hover/code-block:opacity-100 [[data-slot=code-block]>&]:pointer-coarse:opacity-100",
          "[[data-slot=code-block]>&]:*:[button]:bg-background [[data-slot=code-block]>&]:*:[button]:ring-1 [[data-slot=code-block]>&]:*:[button]:ring-foreground/10"
        ]
      }
    end
  end
end
