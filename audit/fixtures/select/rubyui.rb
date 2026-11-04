# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/select (strings in content.yml).
  class Select < Phlex::HTML
    include RubyUI

    def view_template
      Select do
        SelectInput(name: "fruit")
        SelectTrigger(class: "w-56", data: {audit_trigger: true}) do
          SelectValue(placeholder: "Select a fruit")
        end
        SelectContent do
          SelectGroup do
            SelectLabel { "Fruits" }
            SelectItem(value: "apple") { "Apple" }
            SelectItem(value: "banana") { "Banana" }
            SelectItem(value: "blueberry") { "Blueberry" }
            SelectItem(value: "grapes") { "Grapes" }
            SelectItem(value: "pineapple") { "Pineapple" }
          end
        end
      end
    end
  end
end
