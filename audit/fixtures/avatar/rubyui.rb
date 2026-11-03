# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/avatar (strings in content.yml).
  # shadcn sizes default/sm/lg map to RubyUI's :default/:sm/:lg.
  class Avatar < Phlex::HTML
    include RubyUI

    IMAGE_SRC = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='64' height='64'%3E%3Crect width='64' height='64' fill='%233b82f6'/%3E%3C/svg%3E"
    BROKEN_SRC = "data:image/png;base64,AAAA"

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
      end
    end
  end
end
