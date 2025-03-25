# frozen_string_literal: true

module RubyUI
  class AspectRatio < Base
    def initialize(aspect_ratio: "16/9", **attrs)
      raise "aspect_ratio must be in the format of a string with a slash in the middle (eg. '16/9', '1/1')" unless aspect_ratio.is_a?(String) && aspect_ratio.include?("/")

      @aspect_ratio = aspect_ratio
      super(**attrs)
    end

    def view_template(&block)
      div(
        class: "relative w-full",
        style: "padding-bottom: #{padding_bottom}%;"
      ) do
        div(**attrs, &block)
      end
    end

    private

    def padding_bottom
      @aspect_ratio.split("/").map(&:to_i).reverse.reduce(&:fdiv) * 100
    end

    def default_attrs
      {
        class: "bg-muted absolute inset-0 [&>img]:object-cover [&>img]:absolute [&>img]:h-full [&>img]:w-full [&>img]:inset-0 [&>img]:text-transparent"
      }
    end
  end
end
