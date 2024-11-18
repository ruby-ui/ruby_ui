module RubyUI
  module Generators
    class ComponentGenerator < Rails::Generators::Base
      namespace "ruby_ui:component"

      source_root File.expand_path("../../ruby_ui", __dir__)
      argument :component_name, type: :string, required: true

      def generate_component
        if component_not_found?
          say "Component not found: #{component_name}", :red
          exit
        end

        say "Generating component files"
      end

      def copy_main_component_file
        say "Generating main component"

        copy_file File.join(component_folder_path, "#{component_folder_name}.rb"),
          Rails.root.join("app/components/ruby_ui", "#{component_folder_name}.rb")
      end

      def copy_subcomponents_files
        return if subcomponent_file_paths.empty?

        say "Generating subcomponents"

        subcomponent_file_paths.each do |file_path|
          component_file_name = file_path.split("/").last
          copy_file file_path, Rails.root.join("app/components/ruby_ui", component_folder_name, component_file_name)
        end
      end

      def copy_js_files
        return if js_controller_file_paths.empty?

        say "Generating Stimulus controllers"

        js_controller_file_paths.each do |file_path|
          component_file_name = file_path.split("/").last
          copy_file file_path, Rails.root.join("app/javascript/controllers/ruby_ui", component_file_name)
        end

        say "Updating Stimulus controllers manifest"
        run "rake stimulus:manifest:update"
      end

      def copy_dependencies
        case component_folder_name
        when "masked_input"
          copy_masked_input_dependencies
        end
      end

      private

      def component_not_found? = !Dir.exist?(component_folder_path)

      def component_folder_name = component_name.underscore

      def component_folder_path = File.join(self.class.source_root, component_folder_name)

      def main_component_file_path = File.join(component_folder_path, "#{component_folder_name}.rb")

      def subcomponent_file_paths = Dir.glob(File.join(component_folder_path, "*.rb")) - [main_component_file_path]

      def js_controller_file_paths = Dir.glob(File.join(component_folder_path, "*.js"))

      def copy_masked_input_dependencies
        say "Generating masked input dependencies"

        run "bin/rails generate ruby_ui:component Input"
      end
    end
  end
end
