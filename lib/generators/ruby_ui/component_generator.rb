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
          controller_file_name = file_path.split("/").last
          copy_file file_path, Rails.root.join("app/javascript/controllers/ruby_ui", controller_file_name)
        end

        say "Updating Stimulus controllers manifest"
        run "rake stimulus:manifest:update"
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

      def main_component_file_path = File.join(component_folder_path, "#{component_folder_name}.rb")

      def subcomponent_file_paths = Dir.glob(File.join(component_folder_path, "*.rb")) - [main_component_file_path]

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

      def install_js_package(package)
        if File.exist?(Rails.root.join("package-lock.json"))
          run "npm install #{package}"
        elsif File.exist?(Rails.root.join("yarn.lock"))
          run "yarn add #{package}"
        else
          say "Could not detect the package manager, you need to install '#{package}' manually", :red
        end
      end

      def dependencies
        @dependencies ||= YAML.load_file(File.join(__dir__, "dependencies.yml")).freeze

        @dependencies[component_folder_name]
      end
    end
  end
end
