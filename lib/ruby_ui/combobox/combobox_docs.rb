# frozen_string_literal: true

class Views::Docs::Combobox < Views::Base
  def view_template
    component = "Combobox"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: component, description: "Autocomplete input and command palette with a list of suggestions.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Combobox", context: self) do
        <<~RUBY
          div class: "w-96" do
            Combobox do
              ComboboxTrigger placeholder: "Select framework"

              ComboboxPopover do
                ComboboxSearchInput(placeholder: "Search framework...")

                ComboboxList do
                  ComboboxEmptyState { "No results found." }

                  ComboboxListGroup(label: "Ruby") do
                    ComboboxItem do
                      ComboboxRadio(name: "framework", value: "rails")
                      span { "Rails" }
                    end
                    ComboboxItem do
                      ComboboxRadio(name: "framework", value: "hanami")
                      span { "Hanami" }
                    end
                  end

                  ComboboxListGroup(label: "JavaScript") do
                    ComboboxItem do
                      ComboboxRadio(name: "framework", value: "nextjs")
                      span { "Next.js" }
                    end
                    ComboboxItem do
                      ComboboxRadio(name: "framework", value: "nuxt")
                      span { "Nuxt" }
                    end
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Multiselect", context: self) do
        <<~RUBY
          div class: "w-96" do
            Combobox do
              ComboboxBadgeTrigger(placeholder: "Select frameworks...") do
                ComboboxClearButton()
              end

              ComboboxPopover do
                ComboboxList do
                  ComboboxEmptyState { "No results found." }

                  ComboboxListGroup(label: "Ruby") do
                    ComboboxItem do
                      ComboboxCheckbox(name: "frameworks[]", value: "rails")
                      span { "Rails" }
                    end
                    ComboboxItem do
                      ComboboxCheckbox(name: "frameworks[]", value: "hanami")
                      span { "Hanami" }
                    end
                  end

                  ComboboxListGroup(label: "JavaScript") do
                    ComboboxItem do
                      ComboboxCheckbox(name: "frameworks[]", value: "nextjs")
                      span { "Next.js" }
                    end
                    ComboboxItem do
                      ComboboxCheckbox(name: "frameworks[]", value: "nuxt")
                      span { "Nuxt" }
                    end
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          div(class: "w-96") do
            Combobox do
              ComboboxTrigger(disabled: true, placeholder: "Pick value")
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
