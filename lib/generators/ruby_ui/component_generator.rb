require_relative "javascript_utils"
require_relative "engine_utils"
require_relative "phlex_transformer"

module RubyUI
  module Generators
    class ComponentGenerator < Rails::Generators::Base
      include RubyUI::Generators::JavascriptUtils
      include RubyUI::Generators::EngineUtils

      namespace "ruby_ui:component"

      source_root File.expand_path("../../ruby_ui", __dir__)
      argument :component_name, type: :string, required: true
      class_option :force, type: :boolean, default: false
      class_option :with_docs, type: :boolean, default: false
      class_option :engine, type: :string, default: "phlex",
        desc: "Output engine: phlex (default), erb, or herb"

      def generate_component
        if component_not_found?
          say "Component not found: #{component_name}", :red
          exit
        end

        say "Generating #{component_name} files (engine: #{engine})..."
      end

      def copy_related_component_files
        say "Generating components"

        if engine == "phlex"
          generate_phlex_component_files
        else
          copy_erb_component_files
        end
      end

      def copy_js_files
        return if js_controller_file_paths.empty?

        say "Generating Stimulus controllers"

        js_controller_file_paths.each do |file_path|
          controller_file_name = file_path.split("/").last
          copy_file file_path, Rails.root.join("app/javascript/controllers/ruby_ui", controller_file_name), force: options["force"]
        end

        # Importmap doesn't have controller manifest, instead it uses `eagerLoadControllersFrom("controllers", application)`
        unless using_importmap?
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

      def engine
        options["engine"]
      end

      def component_not_found? = !Dir.exist?(component_folder_path)

      def component_folder_name = component_name.underscore

      def component_folder_path = File.join(self.class.source_root, component_folder_name)

      # --engine=phlex: copy pre-generated Phlex classes (_phlex.rb artifacts).
      # Each _phlex.rb is generated at gem build time by PhlexTransformer from
      # the plain Ruby class + Herb template. The consumer app gets a proper
      # Phlex class without needing the herb gem installed.
      def generate_phlex_component_files
        rb_files = EngineUtils.phlex_component_files(
          component_folder_path,
          with_docs: options["with_docs"]
        )

        rb_files.each do |rb_path|
          base_name = File.basename(rb_path, ".rb")
          phlex_path = File.join(component_folder_path, "#{base_name}_phlex.rb")
          dest = Rails.root.join("app/components/ruby_ui", component_folder_name, "#{base_name}.rb")

          if File.exist?(phlex_path)
            # Copy pre-generated Phlex class (renamed to component.rb)
            copy_file phlex_path, dest, force: options["force"]
          else
            # No pre-generated Phlex — copy plain Ruby class as fallback
            copy_file rb_path, dest, force: options["force"]
          end
        end
      end

      # --engine=erb / --engine=herb: copy plain Ruby class + template directly.
      def copy_erb_component_files
        EngineUtils.erb_component_files(
          component_folder_path,
          with_docs: options["with_docs"]
        ).each do |file_path|
          file_name = file_path.split("/").last
          copy_file file_path, Rails.root.join("app/components/ruby_ui", component_folder_name, file_name), force: options["force"]
        end
      end

      def js_controller_file_paths = Dir.glob(File.join(component_folder_path, "*.js"))

      def install_components_dependencies(components)
        components&.each do |component|
          run "bin/rails generate ruby_ui:component #{component} --force #{options["force"]} --engine #{engine}"
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
