# frozen_string_literal: true

module RubyUI
  class CollapsibleSidebar < Base
    def initialize(side: :left, variant: :sidebar, collapsible: :offcanvas, open: true, **attrs)
      @side = side
      @variant = variant
      @collapsible = collapsible
      @open = open
      super(**attrs)
    end

    # Like shadcn, the caller's class/attrs go to the fixed sidebar container,
    # not to the outer peer div that only carries the state.
    def view_template(&)
      MobileSidebar(side: @side, **attrs, &)
      div(**sidebar_attrs) do
        div(**gap_element_attrs)
        div(**mix(content_wrapper_attrs, attrs)) do
          div(**content_attrs, &)
        end
      end
    end

    private

    def sidebar_attrs
      {
        class: "group peer hidden text-sidebar-foreground md:block",
        data: {
          state: @open ? "expanded" : "collapsed",
          collapsible: @open ? "" : @collapsible,
          variant: @variant,
          side: @side,
          slot: "sidebar",
          collapsible_kind: @collapsible,
          ruby_ui__sidebar_target: "sidebar"
        }
      }
    end

    def gap_element_attrs
      {
        class: [
          "relative w-(--sidebar-width) bg-transparent transition-[width]",
          "duration-200 ease-linear",
          "group-data-[collapsible=offcanvas]:w-0",
          "group-data-[side=right]:rotate-180",
          variant_classes
        ],
        data: {slot: "sidebar-gap"}
      }
    end

    def content_wrapper_attrs
      {
        class: [
          "fixed inset-y-0 z-10 hidden h-svh w-(--sidebar-width)",
          "transition-[left,right,width] duration-200 ease-linear md:flex",
          content_wrapper_side_classes,
          content_wrapper_variant_classes
        ],
        data: {slot: "sidebar-container", side: @side}
      }
    end

    def content_attrs
      {
        class: [
          "flex size-full flex-col bg-sidebar",
          "group-data-[variant=floating]:rounded-lg",
          "group-data-[variant=floating]:shadow-sm",
          "group-data-[variant=floating]:ring-1",
          "group-data-[variant=floating]:ring-sidebar-border"
        ],
        data: {
          slot: "sidebar-inner",
          sidebar: "sidebar"
        }
      }
    end

    def variant_classes
      if %i[floating inset].include?(@variant)
        "group-data-[collapsible=icon]:w-[calc(var(--sidebar-width-icon)+(--spacing(4)))]"
      else
        "group-data-[collapsible=icon]:w-(--sidebar-width-icon)"
      end
    end

    def content_wrapper_side_classes
      return "left-0 group-data-[collapsible=offcanvas]:left-[calc(var(--sidebar-width)*-1)]" if @side == :left

      "right-0 group-data-[collapsible=offcanvas]:right-[calc(var(--sidebar-width)*-1)]"
    end

    def content_wrapper_variant_classes
      if %i[floating inset].include?(@variant)
        "p-2 group-data-[collapsible=icon]:w-[calc(var(--sidebar-width-icon)+(--spacing(4))+2px)]"
      else
        "group-data-[collapsible=icon]:w-(--sidebar-width-icon) group-data-[side=left]:border-r group-data-[side=right]:border-l"
      end
    end
  end
end
