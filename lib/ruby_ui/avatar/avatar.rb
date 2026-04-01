# frozen_string_literal: true

module RubyUI
  class Avatar < Base
    SIZES = {
      xs: 'h-4 w-4 text-[0.5rem]',
      sm: 'h-6 w-6 text-xs',
      md: 'h-10 w-10 text-base',
      lg: 'h-14 w-14 text-xl',
      xl: 'h-20 w-20 text-3xl'
    }.freeze

    def initialize(size: :md, **attrs)
      @size = size
      @size_classes = SIZES[@size]
      super(**attrs)
    end

    def view_template(&)
      span(**attrs, &)
    end

    private

    def default_attrs
      {
        class: ['relative flex shrink-0 overflow-hidden rounded-full', @size_classes]
      }
    end
  end
end
