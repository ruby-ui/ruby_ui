# frozen_string_literal: true

class Shared::GridPattern < ApplicationComponent
    def initialize(spacing: :md)
        sizes = {
            xs: 15,
            sm: 25,
            md: 50,
            lg: 100,
            xl: 200,
        }

        @spacing = sizes[spacing]
    end

    def template
        svg(
            class:
                "absolute inset-0 -z-10 h-full w-full stroke-border [mask-image:radial-gradient(100%_100%_at_top_right,white,transparent)]",
            aria_hidden: "true"
        ) do |s|
            s.defs do
                s.pattern(
                id: "0787a7c5-978c-4f66-83c7-11c213f99cb7",
                width: @spacing,
                height: @spacing,
                x: "50%",
                y: "-1",
                patternunits: "userSpaceOnUse"
                ) { s.path(d: "M.5 200V.5H200", fill: "none") }
            end
            s.rect(
                width: "100%",
                height: "100%",
                stroke_width: "0",
                fill: "url(#0787a7c5-978c-4f66-83c7-11c213f99cb7)"
            )
        end
    end
end