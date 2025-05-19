# frozen_string_literal: true

module RubyUI
  class MobileSidebar < Base
    SIDEBAR_WIDTH_MOBILE = "18rem"

    def initialize(side: :left, **attrs)
      @side = side
      super(**attrs)
    end

    def view_template(&)
      Sheet(**attrs) do
        SheetContent(
          side: @side,
          class: "w-[var(--sidebar-width)] bg-sidebar p-0 text-sidebar-foreground [&>button]:hidden",
          style: {
            "--sidebar-width": SIDEBAR_WIDTH_MOBILE
          },
          data: {
            sidebar: "sidebar",
            mobile: "true"
          }
        ) do
          SheetHeader(class: "sr-only") do
            SheetTitle { "Sidebar" }
            SheetDescription { "Displays the mobile sidebar." }
          end
          div(class: "flex h-full w-full flex-col", &)
        end
      end
    end

    private

    def default_attrs
      {
        data: {
          ruby_ui__sidebar_target: "mobileSidebar",
          action: "ruby--ui-sidebar:open->ruby-ui--sheet#open:self"
        }
      }
    end
  end
end
