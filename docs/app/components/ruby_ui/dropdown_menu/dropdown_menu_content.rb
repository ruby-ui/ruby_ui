# frozen_string_literal: true

module RubyUI
  class DropdownMenuContent < Base
    def view_template(&block)
      div(**wrapper_attrs) do
        div(**attrs, &block)
      end
    end

    private

    def default_attrs
      {
        data: {
          state: :open
        },
        class: "z-50 min-w-[8rem] rounded-md border bg-background p-1 text-foreground shadow-md data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 w-56"
      }
    end

    def wrapper_attrs
      {
        class: [
          "z-50 hidden group-[.is-absolute]/dropdown-menu:absolute",
          "group-[.is-fixed]/dropdown-menu:fixed"
        ],
        data: {ruby_ui__dropdown_menu_target: "content"},
        style: {
          width: "max-content",
          top: "0",
          left: "0"
        }
      }
    end
  end
end
