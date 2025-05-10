require_relative "javascript_utils"
module RubyUI
  module Generators
    class ComponentGenerator < Rails::Generators::Base
      include RubyUI::Generators::JavascriptUtils

      namespace "ruby_ui:component"

      source_root File.expand_path("../../ruby_ui", __dir__)
      argument :component_name, type: :string, required: true
      class_option :force, type: :boolean, default: false

      def generate_component
        if component_not_found?
          say "Component not found: #{component_name}", :red
          exit
        end

        say "Generating #{component_name} files..."
      end

      def copy_related_component_files
        say "Generating components"

        components_file_paths.each do |file_path|
          component_file_name = file_path.split("/").last
          copy_file file_path, Rails.root.join("app/components/ruby_ui", component_folder_name, component_file_name), force: options["force"]
        end
      end

      def copy_js_files
        return if js_controller_file_paths.empty?

        say "Generating Stimulus controllers"

        js_controller_file_paths.each do |file_path|
          controller_file_name = file_path.split("/").last
          copy_file file_path, Rails.root.join("app/javascript/controllers/ruby_ui", controller_file_name)
        end

        # Importmap doesn't have controller manifest, instead it uses `eagerLoadControllersFrom("controllers", application)`
        if !using_importmap?
          say "Updating Stimulus controllers manifest"
          run "rake stimulus:manifest:update"
        end
      end

      def install_dependencies
        return if dependencies.blank?

        say "Installing dependencies"

        install_components_dependencies(dependencies["components"])
        install_gems_dependencies(dependencies["gems"])
        install_js_packages(dependencies["js_packages"])
      end

      private

      def component_not_found? = !Dir.exist?(component_folder_path)

      def component_folder_name = component_name.underscore

      def component_folder_path = File.join(self.class.source_root, component_folder_name)

      def components_file_paths = Dir.glob(File.join(component_folder_path, "*.rb"))

      def js_controller_file_paths = Dir.glob(File.join(component_folder_path, "*.js"))

      def install_components_dependencies(components)
        components&.each do |component|
          run "bin/rails generate ruby_ui:component #{component}"
        end
      end

      def install_gems_dependencies(gems)
        gems&.each do |ruby_gem|
          run "bundle show #{ruby_gem} > /dev/null 2>&1 || bundle add #{ruby_gem}"
        end
      end

      def install_js_packages(js_packages)
        js_packages&.each do |js_package|
          install_js_package(js_package)
        end
      end

      def dependencies
        @dependencies ||= YAML.load_file(File.join(__dir__, "dependencies.yml")).freeze

        @dependencies[component_folder_name]
      end
    end
  end
end
