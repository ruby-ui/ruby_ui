# frozen_string_literal: true

class Views::Docs::Combobox < Views::Base
  @@code_example = nil

  def view_template
    component = "Combobox"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: component, description: "Autocomplete input and command palette with a list of suggestions.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Single option", context: self) do
        <<~RUBY
          div class: "w-96" do
            Combobox do
              ComboboxTrigger placeholder: "Pick value"

              ComboboxPopover do
                ComboboxSearchInput(placeholder: "Pick value or type anything")

                ComboboxList do
                  ComboboxEmptyState { "No result" }

                  ComboboxListGroup(label: "Fruits") do
                    ComboboxItem do
                      ComboboxRadio(name: "food", value: "apple")
                      span { "Apple" }
                    end

                    ComboboxItem do
                      ComboboxRadio(name: "food", value: "banana")
                      span { "Banana" }
                    end
                  end

                  ComboboxListGroup(label: "Vegetable") do
                    ComboboxItem do
                      ComboboxRadio(name: "food", value: "brocoli")
                      span { "Broccoli" }
                    end

                    ComboboxItem do
                      ComboboxRadio(name: "food", value: "carrot")
                      span { "Carrot" }
                    end
                  end

                  ComboboxListGroup(label: "Others") do
                    ComboboxItem do
                      ComboboxRadio(name: "food", value: "chocolate")
                      span { "Chocolate" }
                    end

                    ComboboxItem do
                      ComboboxRadio(name: "food", value: "milk")
                      span { "Milk" }
                    end
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Multiple options", context: self) do
        <<~RUBY
          div class: "w-96" do
            Combobox term: "things" do
              ComboboxTrigger placeholder: "Pick value"

              ComboboxPopover do
                ComboboxSearchInput(placeholder: "Pick value or type anything")

                ComboboxList do
                  ComboboxEmptyState { "No result" }

                  ComboboxItem(class: "mt-3") do
                    ComboboxToggleAllCheckbox(name: "all", value: "all")
                    span { "Select all" }
                  end

                  ComboboxListGroup label: "Fruits" do
                    ComboboxItem do
                      ComboboxCheckbox(name: "food", value: "apple")
                      span { "Apple" }
                    end

                    ComboboxItem do
                      ComboboxCheckbox(name: "food", value: "banana")
                      span { "Banana" }
                    end
                  end

                  ComboboxListGroup label: "Vegetable" do
                    ComboboxItem do
                      ComboboxCheckbox(name: "food", value: "brocoli")
                      span { "Broccoli" }
                    end

                    ComboboxItem do
                      ComboboxCheckbox(name: "food", value: "carrot")
                      span { "Carrot" }
                    end
                  end

                  ComboboxListGroup label: "Others" do
                    ComboboxItem do
                      ComboboxCheckbox(name: "food", value: "chocolate")
                      span { "Chocolate" }
                    end

                    ComboboxItem do
                      ComboboxCheckbox(name: "food", value: "milk")
                      span { "Milk" }
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

      render Docs::VisualCodeExample.new(title: "Aria Disabled", context: self) do
        <<~RUBY
          div(class: "w-96") do
            Combobox do
              ComboboxTrigger(aria: {disabled: "true"}, placeholder: "Pick value")
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: "Combobox")

      render Docs::ComponentsTable.new(component_files("Combobox"))
    end
  end
end
