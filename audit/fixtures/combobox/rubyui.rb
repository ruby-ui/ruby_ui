# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/combobox (strings in content.yml).
  class Combobox < Phlex::HTML
    include RubyUI

    ITEMS = %w[Apple Banana Blueberry Grapes Pineapple].freeze

    def view_template
      div(class: "w-64") do
        Combobox(name: "fruit") do
          ComboboxTrigger(data: {audit_trigger: true}) { ComboboxValue() }

          ComboboxContent do
            ComboboxInput(placeholder: "Search", show_trigger: false)
            ComboboxEmpty { "No items found." }

            ComboboxList do
              ComboboxGroup do
                ComboboxLabel { "Fruits" }
                ITEMS.each do |item|
                  ComboboxItem(value: item, selected: item == "Apple") { item }
                end
              end
            end
          end
        end
      end
    end
  end
end
