# frozen_string_literal: true

class Views::Docs::Combobox < Views::Base
  def view_template
    component = "Combobox"
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: component, description: "Autocomplete input with a list of suggestions.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Basic", description: "ComboboxInput is the trigger: typing filters the list, the arrow keys move through it and Enter picks. Each item carries a native radio named after the root's name:, so the form submits the selection.", context: self) do
        <<~RUBY
          div(class: "w-64") do
            Combobox(name: "framework") do
              ComboboxInput(placeholder: "Select a framework")
              ComboboxContent do
                ComboboxEmpty { "No items found." }
                ComboboxList do
                  ComboboxItem(value: "next") { "Next.js" }
                  ComboboxItem(value: "sveltekit") { "SvelteKit" }
                  ComboboxItem(value: "nuxt") { "Nuxt.js" }
                  ComboboxItem(value: "remix") { "Remix" }
                  ComboboxItem(value: "astro") { "Astro" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With clear button", description: "show_clear: adds a button that clears the value; it shows while there is one.", context: self) do
        <<~RUBY
          div(class: "w-64") do
            Combobox(name: "framework_clear") do
              ComboboxInput(placeholder: "Select a framework", show_clear: true)
              ComboboxContent do
                ComboboxEmpty { "No items found." }
                ComboboxList do
                  ComboboxItem(value: "next", selected: true) { "Next.js" }
                  ComboboxItem(value: "sveltekit") { "SvelteKit" }
                  ComboboxItem(value: "nuxt") { "Nuxt.js" }
                  ComboboxItem(value: "remix") { "Remix" }
                  ComboboxItem(value: "astro") { "Astro" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With groups", description: "ComboboxGroup and ComboboxLabel name a set of items; ComboboxSeparator divides them. Groups with no match hide while searching.", context: self) do
        <<~RUBY
          div(class: "w-64") do
            Combobox(name: "food") do
              ComboboxInput(placeholder: "Select a food")
              ComboboxContent do
                ComboboxEmpty { "No items found." }
                ComboboxList do
                  ComboboxGroup do
                    ComboboxLabel { "Fruits" }
                    ComboboxItem(value: "apple") { "Apple" }
                    ComboboxItem(value: "banana") { "Banana" }
                  end
                  ComboboxSeparator()
                  ComboboxGroup do
                    ComboboxLabel { "Vegetables" }
                    ComboboxItem(value: "broccoli") { "Broccoli" }
                    ComboboxItem(value: "carrot") { "Carrot" }
                  end
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled items", context: self) do
        <<~RUBY
          div(class: "w-64") do
            Combobox(name: "framework_disabled_items") do
              ComboboxInput(placeholder: "Select a framework")
              ComboboxContent do
                ComboboxEmpty { "No items found." }
                ComboboxList do
                  ComboboxItem(value: "next") { "Next.js" }
                  ComboboxItem(value: "sveltekit", disabled: true) { "SvelteKit" }
                  ComboboxItem(value: "nuxt") { "Nuxt.js" }
                  ComboboxItem(value: "remix", disabled: true) { "Remix" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          div(class: "w-64") do
            Combobox(name: "framework_disabled", disabled: true) do
              ComboboxInput(placeholder: "Select a framework")
              ComboboxContent do
                ComboboxList do
                  ComboboxItem(value: "next") { "Next.js" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Invalid", context: self) do
        <<~RUBY
          div(class: "w-64") do
            Combobox(name: "framework_invalid") do
              ComboboxInput(placeholder: "Select a framework", aria: {invalid: "true"})
              ComboboxContent do
                ComboboxEmpty { "No items found." }
                ComboboxList do
                  ComboboxItem(value: "next") { "Next.js" }
                  ComboboxItem(value: "remix") { "Remix" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Side", description: "side: (top, right, bottom, left) and align: (start, center, end) place the popup; side_offset: and align_offset: set the gap.", context: self) do
        <<~RUBY
          div(class: "w-64") do
            Combobox(name: "framework_side") do
              ComboboxInput(placeholder: "Opens above")
              ComboboxContent(side: :top) do
                ComboboxEmpty { "No items found." }
                ComboboxList do
                  ComboboxItem(value: "next") { "Next.js" }
                  ComboboxItem(value: "remix") { "Remix" }
                  ComboboxItem(value: "astro") { "Astro" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "In a popup", description: "ComboboxTrigger is a button that shows the value (ComboboxValue); the search input lives inside the popup (show_trigger: false).", context: self) do
        <<~RUBY
          div(class: "w-64") do
            Combobox(name: "country") do
              ComboboxTrigger { ComboboxValue(placeholder: "Select a country") }
              ComboboxContent do
                ComboboxInput(placeholder: "Search", show_trigger: false)
                ComboboxEmpty { "No items found." }
                ComboboxList do
                  ComboboxItem(value: "br", selected: true) { "Brazil" }
                  ComboboxItem(value: "ar") { "Argentina" }
                  ComboboxItem(value: "cl") { "Chile" }
                  ComboboxItem(value: "pt") { "Portugal" }
                  ComboboxItem(value: "us") { "United States" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Multiple", description: "multiple: true picks several items, shown as chips. Backspace on the empty input removes the last one.", context: self) do
        <<~RUBY
          div(class: "w-80") do
            Combobox(name: "frameworks[]", multiple: true) do
              ComboboxChips do
                ComboboxChipsInput(placeholder: "Add framework")
              end
              ComboboxContent do
                ComboboxEmpty { "No items found." }
                ComboboxList do
                  ComboboxItem(value: "next", selected: true) { "Next.js" }
                  ComboboxItem(value: "sveltekit") { "SvelteKit" }
                  ComboboxItem(value: "nuxt") { "Nuxt.js" }
                  ComboboxItem(value: "remix") { "Remix" }
                  ComboboxItem(value: "astro") { "Astro" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Select all", description: "RubyUI extras: ComboboxToggleAll is an option that selects every enabled item, or clears them when all are selected; it hides while searching and also works in a popup (next example). ComboboxChips(max: 3) keeps the box small: past three items the chips collapse into one \"5 frameworks\" chip (term: from the root), whose remove button, like Backspace, clears the selection.", context: self) do
        <<~RUBY
          div(class: "w-80") do
            Combobox(name: "frameworks_all[]", multiple: true, term: "frameworks") do
              ComboboxChips(max: 3) do
                ComboboxChipsInput(placeholder: "Add framework")
              end
              ComboboxContent do
                ComboboxEmpty { "No items found." }
                ComboboxList do
                  ComboboxToggleAll { "Select all" }
                  ComboboxSeparator()
                  ComboboxItem(value: "next") { "Next.js" }
                  ComboboxItem(value: "sveltekit") { "SvelteKit" }
                  ComboboxItem(value: "nuxt") { "Nuxt.js" }
                  ComboboxItem(value: "remix") { "Remix" }
                  ComboboxItem(value: "astro") { "Astro" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Multiple in a popup", description: "The same in a popup. term: shows \"2 fruits\" in the trigger instead of the list of names (RubyUI extra).", context: self) do
        <<~RUBY
          div(class: "w-64") do
            Combobox(name: "fruits[]", multiple: true, term: "fruits") do
              ComboboxTrigger { ComboboxValue(placeholder: "Pick fruits") }
              ComboboxContent do
                ComboboxInput(placeholder: "Search", show_trigger: false)
                ComboboxEmpty { "No items found." }
                ComboboxList do
                  ComboboxToggleAll { "Select all" }
                  ComboboxSeparator()
                  ComboboxItem(value: "apple") { "Apple" }
                  ComboboxItem(value: "banana") { "Banana" }
                  ComboboxItem(value: "blueberry") { "Blueberry" }
                  ComboboxItem(value: "grapes") { "Grapes" }
                end
              end
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Form", description: "required: makes the browser validate the selection: one radio for a single combobox, at least one checkbox for multiple: true. FormField shows the message and marks the visible input invalid.", context: self) do
        <<~RUBY
          form(class: "flex w-80 flex-col gap-4") do
            FormField do
              FormFieldLabel(for: "framework-form-input") { "Framework" }
              Combobox(name: "framework_form", required: true) do
                ComboboxInput(id: "framework-form-input", placeholder: "Select a framework")
                ComboboxContent do
                  ComboboxEmpty { "No items found." }
                  ComboboxList do
                    ComboboxItem(value: "next", input: {data: {value_missing: "Pick a framework"}}) { "Next.js" }
                    ComboboxItem(value: "remix", input: {data: {value_missing: "Pick a framework"}}) { "Remix" }
                    ComboboxItem(value: "astro", input: {data: {value_missing: "Pick a framework"}}) { "Astro" }
                  end
                end
              end
              FormFieldError()
            end
            FormField do
              FormFieldLabel(for: "stack-form-input") { "Stack" }
              Combobox(name: "stack_form[]", multiple: true, required: true) do
                ComboboxChips do
                  ComboboxChipsInput(id: "stack-form-input", placeholder: "Add a tool")
                end
                ComboboxContent do
                  ComboboxEmpty { "No items found." }
                  ComboboxList do
                    ComboboxItem(value: "rails", input: {data: {value_missing: "Pick at least one"}}) { "Rails" }
                    ComboboxItem(value: "hotwire", input: {data: {value_missing: "Pick at least one"}}) { "Hotwire" }
                    ComboboxItem(value: "phlex", input: {data: {value_missing: "Pick at least one"}}) { "Phlex" }
                  end
                end
              end
              FormFieldError()
            end
            Button(type: "submit") { "Submit" }
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
