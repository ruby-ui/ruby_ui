# frozen_string_literal: true

class Views::Docs::Combobox < Views::Base
  def view_template
    component = "Combobox"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: component, description: "Autocomplete input and command palette with a list of suggestions.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Basic", context: self) do
        <<~RUBY
          div(class: "w-96") do
            Combobox do
              ComboboxInputTrigger(placeholder: "Select framework...")

              ComboboxPopover do
                ComboboxList do
                  ComboboxEmptyState { "No results found." }

                  ComboboxItem do
                    ComboboxRadio(name: "framework", value: "rails")
                    span { "Rails" }
                  end
                  ComboboxItem do
                    ComboboxRadio(name: "framework", value: "hanami")
                    span { "Hanami" }
                  end
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
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Popup", context: self) do
        <<~RUBY
          div(class: "w-96") do
            Combobox do
              ComboboxTrigger(placeholder: "Select framework...")

              ComboboxPopover do
                ComboboxSearchInput(placeholder: "Search framework...")

                ComboboxList do
                  ComboboxEmptyState { "No results found." }

                  ComboboxItem do
                    ComboboxRadio(name: "fw2", value: "rails")
                    span { "Rails" }
                  end
                  ComboboxItem do
                    ComboboxRadio(name: "fw2", value: "hanami")
                    span { "Hanami" }
                  end
                  ComboboxItem do
                    ComboboxRadio(name: "fw2", value: "nextjs")
                    span { "Next.js" }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Multiple", context: self) do
        <<~RUBY
          div(class: "w-96") do
            Combobox do
              ComboboxBadgeTrigger(clear_button: true)

              ComboboxPopover do
                ComboboxList do
                  ComboboxEmptyState { "No results found." }

                  ComboboxItem do
                    ComboboxCheckbox(name: "frameworks[]", value: "rails")
                    span { "Rails" }
                  end
                  ComboboxItem do
                    ComboboxCheckbox(name: "frameworks[]", value: "hanami")
                    span { "Hanami" }
                  end
                  ComboboxItem do
                    ComboboxCheckbox(name: "frameworks[]", value: "sinatra")
                    span { "Sinatra" }
                  end
                  ComboboxItem do
                    ComboboxCheckbox(name: "frameworks[]", value: "nextjs", checked: true)
                    span { "Next.js" }
                  end
                  ComboboxItem do
                    ComboboxCheckbox(name: "frameworks[]", value: "nuxt")
                    span { "Nuxt" }
                  end
                  ComboboxItem do
                    ComboboxCheckbox(name: "frameworks[]", value: "svelte")
                    span { "SvelteKit" }
                  end
                  ComboboxItem do
                    ComboboxCheckbox(name: "frameworks[]", value: "remix")
                    span { "Remix" }
                  end
                  ComboboxItem do
                    ComboboxCheckbox(name: "frameworks[]", value: "astro")
                    span { "Astro" }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Groups", context: self) do
        <<~RUBY
          div(class: "w-96") do
            Combobox do
              ComboboxInputTrigger(placeholder: "Select food...")

              ComboboxPopover do
                ComboboxList do
                  ComboboxEmptyState { "No results found." }

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

                  ComboboxListGroup(label: "Vegetables") do
                    ComboboxItem do
                      ComboboxRadio(name: "food", value: "broccoli")
                      span { "Broccoli" }
                    end
                    ComboboxItem do
                      ComboboxRadio(name: "food", value: "carrot")
                      span { "Carrot" }
                    end
                  end

                  ComboboxListGroup(label: "Grains") do
                    ComboboxItem do
                      ComboboxRadio(name: "food", value: "rice")
                      span { "Rice" }
                    end
                    ComboboxItem do
                      ComboboxRadio(name: "food", value: "wheat")
                      span { "Wheat" }
                    end
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Custom Items", context: self) do
        <<~RUBY
          div(class: "w-96") do
            Combobox do
              ComboboxInputTrigger(placeholder: "Select status...")

              ComboboxPopover do
                ComboboxList do
                  ComboboxEmptyState { "No results found." }

                  ComboboxItem do
                    ComboboxRadio(name: "status", value: "backlog", data: {text: "Backlog"})
                    svg(xmlns: "http://www.w3.org/2000/svg", width: "16", height: "16", viewbox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", class: "text-muted-foreground") { |s| s.circle(cx: "12", cy: "12", r: "10") }
                    span { "Backlog" }
                  end
                  ComboboxItem do
                    ComboboxRadio(name: "status", value: "todo", data: {text: "Todo"})
                    svg(xmlns: "http://www.w3.org/2000/svg", width: "16", height: "16", viewbox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", class: "text-blue-500") { |s| s.circle(cx: "12", cy: "12", r: "10") }
                    span { "Todo" }
                  end
                  ComboboxItem do
                    ComboboxRadio(name: "status", value: "done", data: {text: "Done"})
                    svg(xmlns: "http://www.w3.org/2000/svg", width: "16", height: "16", viewbox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", class: "text-green-500") { |s| s.path(d: "M22 11.08V12a10 10 0 1 1-5.93-9.14"); s.path(d: "m9 11 3 3L22 4") }
                    span { "Done" }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Invalid", context: self) do
        <<~RUBY
          div(class: "w-96") do
            Combobox do
              ComboboxInputTrigger(placeholder: "Required field", aria: {invalid: "true"})

              ComboboxPopover do
                ComboboxList do
                  ComboboxEmptyState { "No results found." }

                  ComboboxItem do
                    ComboboxRadio(name: "req", value: "option1")
                    span { "Option 1" }
                  end
                  ComboboxItem do
                    ComboboxRadio(name: "req", value: "option2")
                    span { "Option 2" }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          div(class: "w-96 space-y-2") do
            Combobox do
              ComboboxTrigger(disabled: true, placeholder: "Disabled trigger")
            end

            Combobox do
              ComboboxInputTrigger(placeholder: "Disabled input", disabled: true)
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Auto Highlight", context: self) do
        <<~RUBY
          div(class: "w-96") do
            Combobox do
              ComboboxInputTrigger(placeholder: "Type to search...")

              ComboboxPopover do
                ComboboxList do
                  ComboboxEmptyState { "No results found." }

                  ComboboxItem do
                    ComboboxRadio(name: "color", value: "red")
                    span { "Red" }
                  end
                  ComboboxItem do
                    ComboboxRadio(name: "color", value: "green")
                    span { "Green" }
                  end
                  ComboboxItem do
                    ComboboxRadio(name: "color", value: "blue")
                    span { "Blue" }
                  end
                  ComboboxItem do
                    ComboboxRadio(name: "color", value: "yellow")
                    span { "Yellow" }
                  end
                  ComboboxItem do
                    ComboboxRadio(name: "color", value: "purple")
                    span { "Purple" }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
