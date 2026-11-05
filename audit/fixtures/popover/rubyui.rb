# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/popover (strings in content.yml).
  class Popover < Phlex::HTML
    include RubyUI

    def view_template
      Popover do
        PopoverTrigger do
          Button(variant: :outline, class: "w-fit", data: {audit_trigger: true}) { "Open Popover" }
        end
        PopoverContent(align: :start) do
          PopoverHeader do
            PopoverTitle { "Dimensions" }
            PopoverDescription { "Set the dimensions for the layer." }
          end
        end
      end
    end
  end
end
