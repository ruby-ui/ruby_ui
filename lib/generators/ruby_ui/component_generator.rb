module RubyUI
  module Generators
    class ComponentGenerator < RubyUI::Generators::BaseGenerator
      namespace "ruby_ui:component"

      source_root File.expand_path("../../..", __dir__)
      argument :component_name, type: :string, required: true

      def copy_component
        return puts "This generator can only be run in a Rails environment." unless defined?(Rails::Generators::Base)

        copy_common_files
        copy_component_files
      end

      private

      def copy_common_files
        template "#{template_dir}/index.js", "#{destination_path}/index.js" unless File.exist?("#{destination_path}/index.js")
        copy_file File.join(source_path, "base.rb"), File.join(destination_path, "base.rb")
      end

      def copy_component_files
        puts "Component #{component} not found in ruby_ui gem" if component_source.empty?

        component_files = Dir.glob("#{component_source}/*")

        component_files.each do |file|
          copy_file file, File.join(destination_path, component, File.basename(file))
        end
        update_index_file
      end

      def update_index_file
        index_path = File.join(destination_root, "app/components/ruby_ui/index.js")

        ruby_ui_index_content = File.read(index_path)

        updated_ruby_ui_index_content = add_controller_registration(ruby_ui_index_content)

        File.write(index_path, updated_ruby_ui_index_content)
      end

      def add_controller_registration(ruby_ui_index_content)
        valid_controllers = get_valid_controllers

        ruby_ui_index_content = update_imports(ruby_ui_index_content, valid_controllers)
        update_registrations(ruby_ui_index_content, valid_controllers)
        # Uncomment the following line if you want to update exports
        # ruby_ui_index_content = update_exports(ruby_ui_index_content, valid_controllers)
      end

      def get_valid_controllers
        all_js_controllers = Dir.glob(File.join(destination_path, "**", "*_controller.js"))

        all_js_controllers.map do |controller_file|
          controller_info(controller_file)
        end
      end

      def controller_info(controller_file)
        # Get the relative path from the destination path to the controller file
        relative_path = Pathname.new(controller_file).relative_path_from(Pathname.new(destination_path))

        # Extract the file name without the .js extension
        file_name = relative_path.basename(".js").to_s

        # Remove '_controller' suffix to get the component name
        component_name = file_name.sub(/_controller$/, "")

        # Create the new controller name by camelizing the component name and adding 'Controller'
        new_controller = "#{component_name.camelize}Controller"

        # Build the new import path
        new_import_path = new_import_path("./#{relative_path.dirname}/#{file_name}")

        # Create the registration name by dasherizing the component name and prefixing with 'ruby_ui--'
        registration_name = "ruby_ui--#{component_name.dasherize}"

        # Return a hash with import, registration, and export statements
        {
          # Import statement for importmaps
          import: "import #{new_controller} from \"#{new_import_path}\";",

          # Registration statement for the Stimulus controller
          registration: "application.register(\"#{registration_name}\", #{new_controller});",

          # Export statement for the controller
          export: "export { default as #{new_controller} } from \"#{new_import_path}\";"
        }
      end

      def new_import_path(relative_path)
        if using_importmap?
          "ruby_ui/#{relative_path.sub(/^\.\//, "")}"
        else
          relative_path
        end
      end

      def update_imports(content, controllers)
        imports = controllers.map { |c| c[:import] }.sort.join("\n")
        content.sub(/\/\/ Import all controller files.*?(?=\n\n)/m, "// Import all controller files\n#{imports}")
      end

      def update_registrations(content, controllers)
        registrations = controllers.map { |c| c[:registration] }.sort.join("\n")
        content.sub(/\/\/ Register all controllers.*?(?=\n\n)/m, "// Register all controllers\n#{registrations}")
      end

      def update_exports(content, controllers)
        exports = controllers.map { |c| c[:export] }.sort.join("\n")
        content.sub(/\/\/ Export all controllers.*?(?=\n\n)/m, "// Export all controllers so user of npm package can lazy load controllers\n#{exports}")
      end

      def component
        @component ||= component_name.downcase
      end

      def source_path
        @source_path ||= "lib/ruby_ui"
      end

      def destination_path
        @destination_path ||= "app/components/ruby_ui"
      end

      def component_source
        @component_source ||= File.join(self.class.source_root, source_path, component)
      end

      def template_dir
        @template_dir ||= File.join(__dir__, "templates")
      end
    end
  end
end
