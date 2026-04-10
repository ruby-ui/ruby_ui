# frozen_string_literal: true

module RubyUI
  class Sidebar
    include ComponentBase

    SIDES = %i[left right].freeze
    VARIANTS = %i[sidebar floating inset].freeze
    COLLAPSIBLES = %i[offcanvas icon none].freeze

    def initialize(side: :left, variant: :sidebar, collapsible: :offcanvas, open: true, **attrs)
      raise ArgumentError, "Invalid side: #{side}." unless SIDES.include?(side.to_sym)
      raise ArgumentError, "Invalid collapsible: #{collapsible}." unless COLLAPSIBLES.include?(collapsible.to_sym)

      @side = side.to_sym
      @variant = variant.to_sym
      @collapsible = collapsible.to_sym
      @open = open
      super(**attrs)
    end

    def collapsible?
      @collapsible != :none
    end

    attr_reader :side

    attr_reader :variant

    attr_reader :collapsible

    def open?
      @open
    end
  end
end
