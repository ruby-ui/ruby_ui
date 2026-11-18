# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/avatar (strings in content.yml).
  # shadcn sizes default/sm/lg map to RubyUI's :default/:sm/:lg.
  class Avatar < Phlex::HTML
    include RubyUI

    IMAGE_SRC = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='64' height='64'%3E%3Crect width='64' height='64' fill='%233b82f6'/%3E%3C/svg%3E"
    BROKEN_SRC = "data:image/png;base64,AAAA"
    LOGO_SRC = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='128' height='32' viewBox='0 0 128 32'%3E%3Crect width='43' height='32' fill='%23ef4444'/%3E%3Crect x='43' width='42' height='32' fill='%233b82f6'/%3E%3Crect x='85' width='43' height='32' fill='%2322c55e'/%3E%3C/svg%3E"

    def view_template
      div(class: "flex items-center gap-4", data: {audit_trigger: true}) do
        Avatar do
          AvatarImage(src: IMAGE_SRC, alt: "@shadcn")
          AvatarFallback { "CN" }
        end
        Avatar do
          AvatarFallback { "JD" }
        end
        Avatar do
          AvatarImage(src: BROKEN_SRC, alt: "@broken")
          AvatarFallback { "ER" }
        end
        Avatar(size: :sm) do
          AvatarFallback { "SM" }
        end
        Avatar(size: :lg) do
          AvatarFallback { "LG" }
        end
        Avatar do
          AvatarFallback { "BG" }
          AvatarBadge()
        end
        AvatarGroup do
          Avatar do
            AvatarFallback { "AB" }
          end
          Avatar do
            AvatarFallback { "CD" }
          end
          AvatarGroupCount { "+2" }
        end
        Avatar do
          AvatarImage(src: LOGO_SRC, alt: "@logo", class: "object-contain")
          AvatarFallback { "LO" }
        end
      end
    end
  end
end
