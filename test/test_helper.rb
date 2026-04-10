# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ruby_ui"
require "ruby_ui/component_base"
require "ruby_ui/helpers/tag_attributes"
require "phlex"
require "json"
require "securerandom"
require "minitest/autorun"

module RubyUI
  extend Phlex::Kit

  Dir.glob("lib/ruby_ui/**/*.rb").reject { |f|
    f.include?("/docs/") ||
      f.end_with?("_docs.rb") ||
      f.include?("/helpers/") ||
      f.include?("/herb/") ||
      f.end_with?("component_base.rb")
  }.map do |path|
    class_name = path.split("/").last.delete_suffix(".rb").split("_").map(&:capitalize).join.to_sym
    autoload class_name, path
  end
end

class ComponentTest < Minitest::Test
  def render(component, &)
    component.call(&)
  end

  def phlex(&)
    render Phlex::HTML.new, &
  end
end
