# frozen_string_literal: true

module RubyUI
  class Text < Base
    def initialize(as: 'p', size: '3', weight: 'regular', **attrs)
      @as = as
      @size = size
      @weight = weight
      super(**attrs)
    end

    def view_template(&)
      public_send(@as, **attrs, &)
    end

    private

    def default_attrs
      {
        class: class_names
      }
    end

    def class_names
      "#{size_to_class[@size]} #{weight_to_class[@weight]}"
    end

    def size_to_class
      {
        '1' => 'text-xs', 'xs' => 'text-xs',
        '2' => 'text-sm', 'sm' => 'text-sm',
        '3' => 'text-base', 'base' => 'text-base',
        '4' => 'text-lg', 'lg' => 'text-lg',
        '5' => 'text-xl', 'xl' => 'text-xl',
        '6' => 'text-2xl', '2xl' => 'text-2xl',
        '7' => 'text-3xl', '3xl' => 'text-3xl',
        '8' => 'text-4xl', '4xl' => 'text-4xl',
        '9' => 'text-5xl', '5xl' => 'text-5xl'
      }
    end

    def weight_to_class
      {
        'muted' => 'text-muted-foreground',
        'light' => 'font-light',
        'regular' => 'font-normal',
        'medium' => 'font-medium',
        'semibold' => 'font-semibold',
        'bold' => 'font-bold'
      }
    end
  end
end
