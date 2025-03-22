# frozen_string_literal: true

# "--sidebar-width": SIDEBAR_WIDTH,
# "--sidebar-width-icon": SIDEBAR_WIDTH_ICON,

# TODO: Add keyboard events
# TODO: Open only mobile or normal sidebar
# TODO: state => expanded, collapsed
# TODO: cache

# const MOBILE_BREAKPOINT = 768

module RubyUI
  class Sidebar < Base
    SIDEBAR_WIDTH = "16rem"
    SIDEBAR_WIDTH_ICON = "3rem"

    SIDES = %i[left right].freeze
    VARIANTS = %i[sidebar floating inset].freeze
    COLLAPSIBLES = %i[offcanvas icon none].freeze

    def initialize(side: :left, variant: :sidebar, collapsible: :offcanvas, open: true, **attrs)
      raise ArgumentError, "Invalid side: #{side}. Must be one of #{SIDES}." unless SIDES.include?(side.to_sym)
      raise ArgumentError, "Invalid variant: #{variant}. Must be one of #{VARIANTS}." unless VARIANTS.include?(variant.to_sym)
      raise ArgumentError, "Invalid collapsible: #{collapsible}. Must be one of #{COLLAPSIBLES}." unless COLLAPSIBLES.include?(collapsible.to_sym)

      @side = side.to_sym
      @variant = variant.to_sym
      @collapsible = collapsible.to_sym
      @open = open
      super(**attrs)
    end

    def view_template(&)
      div(**attrs) do
        if @collapsible == :none
          NonCollapsiableSidebar(&)
        else
          MobileSidebar(side: @side, &)
          CollapsiableSidebar(side: @side, variant: @variant, &)
        end
      end
    end

    private

    def default_attrs
      {
        class: "peer group/sidebar has-[[data-variant=inset]]:bg-sidebar",
        style: "--sidebar-width: #{SIDEBAR_WIDTH}; --sidebar-width-icon: #{SIDEBAR_WIDTH_ICON};",
        data: {
          controller: "ruby-ui--sidebar",
          state: @open ? "expanded" : "collapsed",
          collapsible: @open ? "" : @collapsible,
          variant: @variant,
          side: @side,
          ruby_ui__sidebar_open_value: @open.to_s,
          ruby_ui__sidebar_collapsible_value: @collapsible,
          ruby_ui__sidebar_ruby_ui__sheet_outlet: ".ruby-ui--sidebar-sheet"
        }
      }
    end
  end
end
