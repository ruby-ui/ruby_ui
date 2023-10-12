# frozen_string_literal: true

class AspectRatio < ApplicationComponent
  def initialize(aspect_ratio: "16/9")
    raise "aspect_ratio must be in the format of a string with a slash in the middle (eg. '16/9', '1/1')" unless aspect_ratio.is_a?(String) && aspect_ratio.include?("/")
    @aspect_ratio = aspect_ratio
  end

  def template(&)
    div(
      style: "position:relative;width:100%;padding-bottom:#{padding_bottom}%;}",
    ) do
      div(class: "bg-muted", style: "position:absolute;inset:0", &)
    end
  end

  private

  def padding_bottom
    @aspect_ratio.split("/").map(&:to_i).reverse.reduce(&:fdiv) * 100
  end
end
