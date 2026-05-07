# frozen_string_literal: true

class Views::Docs::Switch < Views::Base
  def view_template
    component = "Switch"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Switch", description: "A control that allows the user to toggle between checked and not checked.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Default", context: self) do
        <<~RUBY
          Switch(name: "switch")
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Checked", context: self) do
        <<~RUBY
          Switch(name: "switch", checked: true)
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Disabled", context: self) do
        <<~RUBY
          Switch(name: "switch", disabled: true)
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Aria Disabled", context: self) do
        <<~RUBY
          Switch(name: "switch", aria: {disabled: "true"})
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With flag include_hidden false", context: self) do
        <<~RUBY
          # Supports the creation of a hidden input to be used in forms inspired by the Ruby on Rails implementation of check_box. Default is true.
          Switch(name: "switch", include_hidden: false)
        RUBY
      end

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
