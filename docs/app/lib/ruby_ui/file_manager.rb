module RubyUI
  module FileManager
    extend self

    def main_component_code(component_name)
      component_code main_component_file_path(component_name)
    end

    def component_code(file_path)
      File.read(file_path) if File.exist?(file_path)
    end

    def component_file_paths(component_name)
      Dir[File.join(component_folder(component_name), "*.rb")]
    end

    def stimulus_controller_file_paths(component_name)
      Dir[File.join(component_folder(component_name), "*.js")]
    end

    def component_folder(component_name)
      component_name = component_name.underscore
      File.join(gem_path, "lib", "ruby_ui", component_name)
    end

    def dependencies(component_name)
      DEPENDENCIES[component_name.underscore].to_h
    end

    def gem_path
      @gem_path ||= Gem::Specification.find_by_name("ruby_ui").gem_dir
    end

    DEPENDENCIES = YAML.load_file(File.join(gem_path, "lib/generators/ruby_ui/dependencies.yml")).freeze
  end
end
