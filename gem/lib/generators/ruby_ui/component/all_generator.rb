module RubyUI
  module Generators
    module Component
      class AllGenerator < Rails::Generators::Base
        namespace "ruby_ui:component:all"

        source_root File.expand_path("../../../ruby_ui", __dir__)
        class_option :force, type: :boolean, default: false

        def generate_components
          say "Generating all components..."

          folder_names = Dir.children(self.class.source_root).reject { |folder_name| folder_name.ends_with?(".rb") }

          run "bin/rails generate ruby_ui:component #{folder_names.join(" ")} --force #{options["force"]}"
        end
      end
    end
  end
end
