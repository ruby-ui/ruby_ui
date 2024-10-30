# frozen_string_literal: true

module RBUI
  class Text < Base
    def initialize(as: "p", size: "3", weight: "regular", **attrs)
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
        "1" => "text-xs",
        "2" => "text-sm",
        "3" => "text-base",
        "4" => "text-lg",
        "5" => "text-xl",
        "6" => "text-2xl",
        "7" => "text-3xl",
        "8" => "text-4xl",
        "9" => "text-5xl"
      }
    end

    def weight_to_class
      {
        "light" => "font-light",
        "regular" => "font-normal",
        "medium" => "font-medium",
        "semibold" => "font-semibold",
        "bold" => "font-bold"
      }
    end
  end
end
