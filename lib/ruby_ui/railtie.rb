module RubyUI
  if defined?(Rails)
    class Railtie < ::Rails::Railtie
      generators do
        require_relative "../generators/rbui/install/install_generator"

        config.app_generators do |g|
          g.templates.unshift File.expand_path("../templates", __FILE__)
        end

        initializer "rbui.set_generator_namespace" do
          Rails::Generators.namespace(RubyUI::Generators, as: "rbui")
        end
      end

      # Add component loading
      config.to_prepare do
        # Define the path to the RubyUI components
        rbui_components_path = Rails.root.join("app/components/rbui")

        # Check if the RubyUI components directory exists
        if Dir.exist?(rbui_components_path)
          # Find all Ruby files in the RubyUI components directory and its subdirectories
          Dir[rbui_components_path.join("**", "*.rb")].each do |file|
            # Get the relative path of the file from the RubyUI components directory
            relative_path = Pathname.new(file).relative_path_from(rbui_components_path)

            # Convert the file path to a component name
            # e.g., "form/input.rb" becomes ["Form", "Input"]
            component_name_parts = relative_path.to_s.chomp(".rb").split("/").map(&:camelize)

            # Create the full component name with RubyUI namespace
            # e.g., "RubyUI::Form::Input"
            full_component_name = "RubyUI::#{component_name_parts.join("::")}"

            begin
              # Check if the component is already defined
              if defined?(full_component_name.constantize)
                # If it's defined, load (or reload) the file
                load file
              end
            rescue NameError
              # If the constant isn't defined (i.e., the component doesn't exist),
              # we'll skip this file and move to the next one
              next
            end
          end
        end
      end
    end
  end
end
