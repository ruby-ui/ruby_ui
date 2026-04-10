# frozen_string_literal: true

module RubyUI
  class Heading < Base
    def initialize(level: nil, as: nil, size: nil, **attrs)
      @level = level
      @as = as
      @size = size
      super(**attrs)
    end

    def tag_name
      return @as if @as
      return "h#{@level}" if @level
      "h1"
    end

    def view_template(&)
      public_send(tag_name.to_sym, **attrs, &)
    end

    private

    def default_attrs
      {class: class_names}
    end

    def class_names
      base_classes = "scroll-m-20 font-bold tracking-tight"
      size_class = size_to_class[(@size || level_to_size[@level&.to_s] || "6").to_s]
      "#{base_classes} #{size_class}"
    end

    def size_to_class
      {
        "1" => "text-xs",
        "2" => "text-sm",
        "3" => "text-base",
        "4" => "text-lg",
        "5" => "text-xl",
        "6" => "text-2xl",
        "7" => "text-3xl lg:text-4xl",
        "8" => "text-4xl",
        "9" => "text-5xl"
      }
    end

    def level_to_size
      {
        "1" => "7",
        "2" => "6",
        "3" => "5",
        "4" => "4"
      }
    end
  end
end
