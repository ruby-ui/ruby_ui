# frozen_string_literal: true

module RubyUI
  class CollapsiableSidebar < Base
    SIDEBAR_WIDTH = '16rem'
    SIDEBAR_WIDTH_ICON = '3rem'

    def initialize(side: :left, variant: :sidebar, collapsible: :offcanvas, open: true, **attrs)
      @side = side
      @variant = variant
      @collapsible = collapsible
      @open = open
      super(**attrs)
    end

    def view_template(&)
      div(**attrs) do
        MobileSidebar(side: @side, &)
        div(**wrapper_attrs) do
          div(**gap_element_attrs)
          div(**content_wrapper_attrs) do
            div(**content_attrs, &)
          end
        end
      end
    end

    private

    def default_attrs
      {
        class: 'group/sidebar',
        style: "--sidebar-width: #{SIDEBAR_WIDTH}; --sidebar-width-icon: #{SIDEBAR_WIDTH_ICON};",
        data: {
          state: @open ? 'expanded' : 'collapsed',
          collapsible: @open ? '' : @collapsible,
          variant: @variant,
          side: @side,
          collapsible_kind: @collapsible,
          ruby_ui__sidebar_target: 'sidebar'
        }
      }
    end

    def wrapper_attrs
      {
        class: 'peer hidden text-sidebar-foreground md:block'
      }
    end

    def gap_element_attrs
      {
        class: [
          'relative w-[--sidebar-width] bg-transparent transition-[width]',
          'duration-200 ease-linear',
          'group-data-[collapsible=offcanvas]/sidebar:w-0',
          'group-data-[side=right]/sidebar:rotate-180',
          variant_classes
        ]
      }
    end

    def content_wrapper_attrs
      {
        class: [
          'fixed inset-y-0 z-10 hidden h-svh w-[--sidebar-width]',
          'transition-[left,right,width] duration-200 ease-linear md:flex',
          content_wrapper_side_classes,
          content_wrapper_variant_classes
        ]
      }
    end

    def content_attrs
      {
        class: [
          'flex h-full w-full flex-col bg-sidebar',
          'group-data-[variant=floating]/sidebar:rounded-lg',
          'group-data-[variant=floating]/sidebar:border',
          'group-data-[variant=floating]/sidebar:border-sidebar-border',
          'group-data-[variant=floating]/sidebar:shadow'
        ],
        data: {
          sidebar: 'sidebar'
        }
      }
    end

    def variant_classes
      if %i[floating inset].include?(@variant)
        'group-data-[collapsible=icon]/sidebar:w-[calc(var(--sidebar-width-icon)_+_theme(spacing.4))]'
      else
        'group-data-[collapsible=icon]/sidebar:w-[--sidebar-width-icon]'
      end
    end

    def content_wrapper_side_classes
      return 'left-0 group-data-[collapsible=offcanvas]/sidebar:left-[calc(var(--sidebar-width)*-1)]' if @side == :left

      'right-0 group-data-[collapsible=offcanvas]/sidebar:right-[calc(var(--sidebar-width)*-1)]'
    end

    def content_wrapper_variant_classes
      if %i[floating inset].include?(@variant)
        'p-2 group-data-[collapsible=icon]/sidebar:w-[calc(var(--sidebar-width-icon)_+_theme(spacing.4)_+2px)]'
      else
        'group-data-[collapsible=icon]/sidebar:w-[--sidebar-width-icon] group-data-[side=left]/sidebar:border-r group-data-[side=right]/sidebar:border-l'
      end
    end
  end
end
