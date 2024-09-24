# frozen_string_literal: true

class Docs::ComboboxView < ApplicationView
  @@code_example = nil

  def view_template
    component = "Combobox"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: component, description: "Autocomplete input and command palette with a list of suggestions.")

      TypographyH2 { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        @@code_example = <<~RUBY
          div(class: "w-96") do
            Combobox do
              ComboboxInput()
              ComboboxTrigger do
                ComboboxValue(placeholder: "Select event...")
              end
              ComboboxContent do
                ComboboxSearchInput(placeholder: "Search event...")
                ComboboxList do
                  ComboboxEmpty { "No results found." }
                  ComboboxGroup(heading: "Suggestions") do
                    ComboboxItem(value: "railsworld") do
                      span { "Rails World" }
                    end
                    ComboboxItem(value: "tropicalrb") do
                      span { "Tropical.rb" }
                    end
                    ComboboxItem(value: "friendly.rb") do
                      span { "Friendly.rb" }
                    end
                  end

                  ComboboxSeparator()

                  ComboboxGroup(heading: "Others") do
                    ComboboxItem(value: "railsconf") do
                      span { "RailsConf" }
                    end
                    ComboboxItem(value: "euruko") do
                      span { "Euruko" }
                    end
                    ComboboxItem(value: "rubykaigi") do
                      span { "RubyKaigi" }
                    end
                  end
                end
              end
            end
          end
        RUBY
      end
      render Docs::ComponentsTable.new(component_references(component, @@code_example), component_files("Combobox"))
    end
  end
end
