# frozen_string_literal: true

module RubyUI
  class AspectRatio < Base
    # ratio: width / height, as a Numeric (16.0 / 9, 1.5) or a "W/H" String ("16/9", "2.39/1").
    # aspect_ratio: is the deprecated name of ratio:.
    def initialize(ratio: nil, aspect_ratio: nil, **attrs)
      unless aspect_ratio.nil?
        Warning.warn("RubyUI::AspectRatio: `aspect_ratio:` is deprecated, use `ratio:`\n", category: :deprecated)
      end

      ratio = aspect_ratio if ratio.nil?
      @ratio = parse_ratio(ratio.nil? ? "16/9" : ratio)
      user_style = attrs.delete(:style)
      super(**attrs)
      @attrs[:style] = ratio_style(user_style)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def parse_ratio(value)
      ratio =
        case value
        when Numeric then value.to_f if value.real?
        when String
          width, height = value.split("/", 2)
          height ? Float(width) / Float(height) : Float(width)
        end
      return ratio if ratio&.finite? && ratio.positive?

      raise ArgumentError
    rescue ArgumentError, TypeError
      raise ArgumentError, "ratio must be a positive Numeric (16.0 / 9) or a \"W/H\" String (\"16/9\"), got #{value.inspect}"
    end

    # Phlex's mix can't combine a String style with a Hash one, so the caller's
    # style is merged here, in whichever form it came.
    def ratio_style(user_style)
      case user_style
      when nil then "--ratio: #{@ratio};"
      when Hash then {"--ratio" => @ratio}.merge(user_style)
      else "--ratio: #{@ratio}; #{user_style}"
      end
    end

    def default_attrs
      {
        data: {slot: "aspect-ratio"},
        class: "relative aspect-(--ratio)"
      }
    end
  end
end
