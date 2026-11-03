require "chunky_png"

module ShadcnAudit
  module Collect
    # Pixel diff between the two sides' screenshots. Evidence only: it never
    # sets a line's status (font and antialiasing noise make it unreliable).
    module PixelDiff
      CHANNEL_TOLERANCE = 16
      MARK = ChunkyPNG::Color.rgba(255, 0, 0, 255)

      def self.compare(rubyui_png:, shadcn_png:, diff_png:)
        a = ChunkyPNG::Image.from_file(rubyui_png)
        b = ChunkyPNG::Image.from_file(shadcn_png)
        if [a.width, a.height] != [b.width, b.height]
          return {"error" => "size #{a.width}x#{a.height} vs #{b.width}x#{b.height}"}
        end

        diff = ChunkyPNG::Image.new(b.width, b.height)
        pixels = 0
        a.pixels.each_with_index do |pa, i|
          pb = b.pixels[i]
          if differs?(pa, pb)
            pixels += 1
            diff.pixels[i] = MARK
          else
            diff.pixels[i] = ChunkyPNG::Color.fade(pb, 64)
          end
        end
        diff.save(diff_png)
        {"pixels" => pixels, "ratio" => (pixels.to_f / a.pixels.size).round(6), "diff" => diff_png.to_s}
      end

      def self.differs?(pa, pb)
        return false if pa == pb

        %i[r g b a].any? { |c| (ChunkyPNG::Color.send(c, pa) - ChunkyPNG::Color.send(c, pb)).abs > CHANNEL_TOLERANCE }
      end
    end
  end
end
