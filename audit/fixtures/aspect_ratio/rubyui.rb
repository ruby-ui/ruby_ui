# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/aspect_ratio (strings in content.yml).
  class AspectRatio < Phlex::HTML
    include RubyUI

    IMAGE_SRC = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='640' height='360' viewBox='0 0 640 360'%3E%3Crect width='640' height='360' fill='%23737373'/%3E%3Ccircle cx='320' cy='180' r='120' fill='%23d4d4d4'/%3E%3C/svg%3E"
    # What next/image `fill` renders in shadcn's example (the shadcn fixture writes it by hand too).
    IMAGE_STYLE = "position: absolute; height: 100%; width: 100%; inset: 0px; color: transparent;"

    def view_template
      div(id: "aspect-ratio-fixture", class: "w-96") do
        AspectRatio(ratio: 16.0 / 9, class: "rounded-lg bg-muted") do
          img(src: IMAGE_SRC, alt: "Photo", data: {audit_trigger: true}, style: IMAGE_STYLE, class: "h-full w-full rounded-lg object-cover")
        end
      end
    end
  end
end
