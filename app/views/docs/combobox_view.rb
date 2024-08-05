# frozen_string_literal: true

class Docs::ComboboxView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Combobox", description: "Autocomplete input and command palette with a list of suggestions.", premium: @premium)

      TypographyH2 { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self, premium: @premium) do
        <<~RUBY
          Combobox do
            ComboboxTrigger(placeholder: "Select event...", aria_controls: "list")
            ComboboxContent(id: "list") do
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
        RUBY
      end
      render Docs::ComponentsTable.new(components)
    end
  end

  private

  def components
    [
      Docs::ComponentStruct.new(name: "ComboboxController", source: "https://github.com/PhlexUI/phlex_ui_stimulus_pro/blob/main/controllers/command_controller.js", built_using: :stimulus),
      Docs::ComponentStruct.new(name: "ComboboxSeparator", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/command/dialog.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "ComboboxTrigger", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/command/dialog_trigger.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "ComboboxContent", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/command/dialog_content.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "Combobox", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/command.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "ComboboxSearchInput", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/command/input.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "ComboboxList", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/command/list.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "ComboboxGroup", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/command/group.rb", built_using: :phlex),
      Docs::ComponentStruct.new(name: "ComboboxItem", source: "https://github.com/PhlexUI/phlex_ui_pro/blob/main/lib/phlex_ui_pro/command/item.rb", built_using: :phlex)
    ]
  end
end
