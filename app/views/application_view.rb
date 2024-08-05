# frozen_string_literal: true

class ApplicationView < ApplicationComponent
  include RBUI
  # The ApplicationView is an abstract class for all your views.

  # By default, it inherits from `ApplicationComponent`, but you
  # can change that to `Phlex::HTML` if you want to keep views and
  # components independent.

  def components(component, code_example = nil, use_component_files = false)
    return [] unless code_example

    component_names = code_example.scan(/(?<=^|\s)Combobox\w*/).uniq

    component_names.map do |name|
      Docs::ComponentStruct.new(
        name: name,
        source: "https://github.com/PhlexUI/phlex_ui/blob/v1/lib/rbui/#{component.downcase}/#{name.underscore}.rb",
        built_using: :phlex
      )
    end.push(
      Docs::ComponentStruct.new(
        name: "ComboboxController",
        source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/command_controller.js",
        built_using: :stimulus
      )
    )
  end

  require "rubygems"

  def component_files(component, gem_name = "phlex_ui")
    # Find the gem specification
    gem_spec = Gem::Specification.find_by_name(gem_name)
    return [] unless gem_spec

    # Construct the path to the component files within the gem
    component_dir = File.join(gem_spec.gem_dir, "lib", "rbui", component.to_s.downcase)

    return [] unless Dir.exist?(component_dir)

    # Get all Ruby and JavaScript files
    rb_files = Dir.glob(File.join(component_dir, "*.rb"))
    js_files = Dir.glob(File.join(component_dir, "*_controller.js"))

    # Combine and process all files
    (rb_files + js_files).map do |file|
      ext = File.extname(file)
      basename = File.basename(file, ext)

      name = basename.camelize
      source = "https://github.com/PhlexUI/phlex_ui/blob/v1/lib/rbui/#{component.to_s.downcase}/#{File.basename(file)}"
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
end
