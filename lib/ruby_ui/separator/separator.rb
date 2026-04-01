# frozen_string_literal: true

module RubyUI
  class Separator < Base
    ORIENTATIONS = %i[horizontal vertical].freeze

    def initialize(as: :div, orientation: :horizontal, decorative: true, **attrs)
      raise ArgumentError, "Invalid orientation: #{orientation}" unless ORIENTATIONS.include?(orientation.to_sym)

      @as = as
      @orientation = orientation.to_sym
      @decorative = decorative
      super(**attrs)
    end

    def view_template(&)
      tag(@as, **attrs, &)
    end

    private

    def default_attrs
      {
        role: (@decorative ? 'none' : 'separator'),
        class: [
          'shrink-0 bg-border',
          orientation_classes
        ]
      }
    end

    def orientation_classes
      return 'h-[1px] w-full' if @orientation == :horizontal

      'h-full w-[1px]'
    end
  end
end
