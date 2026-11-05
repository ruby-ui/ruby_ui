# frozen_string_literal: true

class Views::Docs::Progress < Views::Base
  def view_template
    component = "Progress"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Progress", description: "Displays an indicator showing the completion progress of a task, typically displayed as a progress bar.")

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Progress(value: 50, class: "w-[60%]", aria: {label: "Progress"})
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With label", description: "ProgressLabel names the progress bar (aria-labelledby on the root); ProgressValue shows the formatted value.", context: self) do
        <<~RUBY
          Progress(value: 56, class: "w-[60%]") do
            ProgressLabel { "Upload progress" }
            ProgressValue()
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Min and max", description: "The bar fills to the percentage of value between min: and max:. aria: {valuetext:} replaces the default text (43%).", context: self) do
        <<~RUBY
          Progress(value: 3, max: 7, class: "w-[60%]", aria: {valuetext: "Step 3 of 7"}) do
            ProgressLabel { "Onboarding" }
            ProgressValue { |_formatted, value| "\#{value.to_i} of 7" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Indeterminate", description: "value: nil means the progress is unknown: no aria-valuenow, and every part gets data-indeterminate to style it.", context: self) do
        <<~RUBY
          Progress(value: nil, class: "w-[60%]") do
            ProgressLabel { "Preparing export" }
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With custom indicator color", context: self) do
        <<~RUBY
          Progress(value: 35, class: "w-[60%] **:data-[slot=progress-indicator]:bg-green-600", aria: {label: "Progress"})
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
