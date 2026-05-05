# frozen_string_literal: true

class Views::Docs::Progress < Views::Base
  def view_template
    component = "Progress"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Progress", description: "Displays an indicator showing the completion progress of a task, typically displayed as a progress bar.")

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          Progress(value: 50, class: "w-[60%]")
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With custom indicator color", context: self) do
        <<~RUBY
          Progress(value: 35, class: "w-[60%] [&>*]:bg-success")
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
