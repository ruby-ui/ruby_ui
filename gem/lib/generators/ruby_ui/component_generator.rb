require_relative "javascript_utils"
module RubyUI
  module Generators
    class ComponentGenerator < Rails::Generators::Base
      include RubyUI::Generators::JavascriptUtils

      namespace "ruby_ui:component"

      source_root File.expand_path("../../ruby_ui", __dir__)
      argument :component_names, type: :array, required: true, banner: "Button Link Input"
      class_option :force, type: :boolean, default: false
      class_option :with_docs, type: :boolean, default: false

      def generate_components
        validate_components!

        component_names.each do |component_name|
          say "Generating #{component_name} files..."
          copy_related_component_files(component_name)
          copy_js_files(component_name)
          install_dependencies(component_name)
        end

        update_stimulus_manifest
      end

      private

      def validate_components!
        missing = component_names.reject { |name| component_exists?(name) }
        return if missing.empty?

        say "Component(s) not found: #{missing.join(", ")}", :red
        exit 1
      end

      def copy_related_component_files(component_name)
        say "Generating components"

        components_file_paths(component_name).each do |file_path|
          component_file_name = file_path.split("/").last
          copy_file file_path, Rails.root.join("app/components/ruby_ui", component_folder_name(component_name), component_file_name), force: options["force"]
        end
      end

      def copy_js_files(component_name)
        paths = js_controller_file_paths(component_name)
        return if paths.empty?

        say "Generating Stimulus controllers"

        paths.each do |file_path|
          controller_file_name = file_path.split("/").last
          copy_file file_path, Rails.root.join("app/javascript/controllers/ruby_ui", controller_file_name), force: options["force"]
        end

        @stimulus_controllers_added = true
      end

      def update_stimulus_manifest
        return unless @stimulus_controllers_added

        # Importmap doesn't have controller manifest, instead it uses `eagerLoadControllersFrom("controllers", application)`
        return if using_importmap?

        say "Updating Stimulus controllers manifest"
        run "rake stimulus:manifest:update"
      end

      def install_dependencies(component_name)
        deps = dependencies(component_name)
        return if deps.blank?

        say "Installing dependencies"

        install_components_dependencies(deps["components"])
        install_gems_dependencies(deps["gems"])
        install_js_packages(deps["js_packages"])
      end

      def component_exists?(component_name) = Dir.exist?(component_folder_path(component_name))

      def component_folder_name(component_name) = component_name.underscore

      def component_folder_path(component_name) = File.join(self.class.source_root, component_folder_name(component_name))

      def components_file_paths(component_name)
        files = Dir.glob(File.join(component_folder_path(component_name), "*.rb"))
        options["with_docs"] ? files : files.reject { |f| f.end_with?("_docs.rb") }
      end

      def js_controller_file_paths(component_name) = Dir.glob(File.join(component_folder_path(component_name), "*.js"))

      def install_components_dependencies(components)
        components&.each do |component|
          run "bin/rails generate ruby_ui:component #{component} --force #{options["force"]}"
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

      def dependencies(component_name)
        @dependencies ||= YAML.load_file(File.join(__dir__, "dependencies.yml")).freeze

        @dependencies[component_folder_name(component_name)]
      end
    end
  end
end
