# frozen_string_literal: true

module Components
  class Heading < Base
    def initialize(level: nil, as: nil, size: nil, **attrs)
      @level = level
      @as = as
      @size = size
      super(**attrs)
    end

    def view_template(&)
      tag = determine_tag
      public_send(tag, **attrs, &)
    end

    private

    def determine_tag
      return @as if @as
      return "h#{@level}" if @level
      "h1"
    end

    def default_attrs
      {
        class: class_names
      }
    end

    def class_names
      base_classes = "scroll-m-20 font-bold tracking-tight"
      size_class = size_to_class[@size || level_to_size[@level] || "6"]
      tag = determine_tag
      "#{base_classes} #{size_class} #{component_specific_classes(tag)}"
    end

    def component_specific_classes(tag)
      component_classes[tag] || ""
    end

    def component_classes
      {
        "h1" => "scroll-m-20 text-3xl font-bold leading-normal lg:leading-normal tracking-tight lg:text-4xl",
        "h2" => "scroll-m-20 text-2xl font-semibold tracking-tight transition-colors first:mt-0 pb-4 border-b",
        "h4" => "scroll-m-20 text-lg font-medium tracking-tight"
      }
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

    def level_to_size
      {
        "1" => "6",
        "2" => "5",
        "3" => "4",
        "4" => "3"
      }
    end
  end
end
