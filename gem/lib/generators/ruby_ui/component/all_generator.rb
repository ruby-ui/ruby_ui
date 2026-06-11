module RubyUI
  module Generators
    module Component
      class AllGenerator < Rails::Generators::Base
        namespace "ruby_ui:component:all"

        source_root File.expand_path("../../../ruby_ui", __dir__)
        class_option :force, type: :boolean, default: false

        def generate_components
          say "Generating all components..."

          # Each component lives in its own directory; select directories only so stray
          # files (e.g. base.rb or a macOS .DS_Store) are never passed as component names.
          folder_names = Dir.children(self.class.source_root).select do |entry|
            File.directory?(File.join(self.class.source_root, entry))
          end

          run "bin/rails generate ruby_ui:component #{folder_names.join(" ")} --force #{options["force"]}"
        end
      end
    end
  end
end
