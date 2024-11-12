require "rubygems"

module ApplicationHelper
  def component_files(component, gem_name = "ruby_ui")
    # Find the gem specification
    gem_spec = Gem::Specification.find_by_name(gem_name)
    return [] unless gem_spec

    # Construct the path to the component files within the gem
    component_dir = File.join(gem_spec.gem_dir, "lib", "ruby_ui", camel_to_snake(component))

    return [] unless Dir.exist?(component_dir)

    # Get all Ruby and JavaScript files
    rb_files = Dir.glob(File.join(component_dir, "*.rb"))
    js_files = Dir.glob(File.join(component_dir, "*_controller.js"))

    # Combine and process all files
    (rb_files + js_files).map do |file|
      ext = File.extname(file)
      basename = File.basename(file, ext)

      name = basename.camelize
      # source = "https://github.com/PhlexUI/phlex_ui/blob/v1/lib/ruby_ui/#{component.to_s.downcase}/#{File.basename(file)}"
      source = "lib/ruby_ui/#{camel_to_snake(component)}/#{File.basename(file)}"
      built_using = if ext == ".rb"
        :phlex
      else # ".js"
        :stimulus
      end

      Docs::ComponentStruct.new(
        name: name,
        source: source,
        built_using: built_using
      )
    end
  end

  def camel_to_snake(string)
    string.gsub("::", "/")
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr("-", "_")
      .downcase
  end

  def snake_to_camel(string)
    string.split("_").map(&:capitalize).join
  end
end
