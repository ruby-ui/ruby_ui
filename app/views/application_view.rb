# frozen_string_literal: true

class MethodCallFinder < Prism::Visitor
  attr_reader :calls

  def initialize(calls)
    @calls = calls
  end

  def visit_call_node(node)
    super
    calls << node.name
  end
end

class ApplicationView < ApplicationComponent
  include RBUI
  # The ApplicationView is an abstract class for all your views.

  # By default, it inherits from `ApplicationComponent`, but you
  # can change that to `Phlex::HTML` if you want to keep views and
  # components independent.

  GITHUB_REPO_URL = "https://github.com/rbui-labs/rbui/"
  GITHUB_FILE_URL = "#{GITHUB_REPO_URL}blob/main/"

  def before_template
    Docs::VisualCodeExample.reset_collected_code
    super
  end

  def component_references(component, code_example = nil, use_component_files = false)
    return [] unless code_example

    calls = []
    Prism.parse(code_example).value.accept(MethodCallFinder.new(calls))
    calls_set = Set.new(calls.map(&:to_s))
    descendants = Phlex::HTML.descendants.map { |d| d.to_s.gsub(/^RBUI::/, "") }
    component_names = descendants.select { |d| calls_set.include?(d) }

    # component_names = code_example.scan(/(?<=^|\s)#{component}\w*/).uniq

    component_names.map do |name|
      Docs::ComponentStruct.new(
        name: name,
        source: "lib/rbui/#{camel_to_snake(component)}/#{camel_to_snake(name)}.rb",
        built_using: :phlex
      )
    end

    # component_names.push(
    #   Docs::ComponentStruct.new(
    #     name: "ComboboxController",
    #     source: "https://github.com/PhlexUI/phlex_ui_stimulus/blob/main/controllers/command_controller.js",
    #     built_using: :stimulus
    #   )
    # )
  end

  require "rubygems"

  def component_files(component, gem_name = "ruby_ui")
    # Find the gem specification
    gem_spec = Gem::Specification.find_by_name(gem_name)
    return [] unless gem_spec

    # Construct the path to the component files within the gem
    component_dir = File.join(gem_spec.gem_dir, "lib", "rbui", camel_to_snake(component))

    return [] unless Dir.exist?(component_dir)

    # Get all Ruby and JavaScript files
    rb_files = Dir.glob(File.join(component_dir, "*.rb"))
    js_files = Dir.glob(File.join(component_dir, "*_controller.js"))

    # Combine and process all files
    (rb_files + js_files).map do |file|
      ext = File.extname(file)
      basename = File.basename(file, ext)

      name = basename.camelize
      # source = "https://github.com/PhlexUI/phlex_ui/blob/v1/lib/rbui/#{component.to_s.downcase}/#{File.basename(file)}"
      source = "lib/rbui/#{camel_to_snake(component)}/#{File.basename(file)}"
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
