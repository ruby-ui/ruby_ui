# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ruby_ui"
require "phlex"
require "json"

require "minitest/autorun"

module RubyUI
  extend Phlex::Kit

  Dir.glob("lib/ruby_ui/**/*.rb").map do |path|
    class_name = path.split("/").last.delete_suffix(".rb").split("_").map(&:capitalize).join.to_sym

    autoload class_name, path
  end
end

def phlex_context(&)
  render Phlex::HTML.new, &
end

module Phlex
  module Testing
    module ViewHelper
      def render(component, &)
        component.call(view_context:, &)
      end

      def view_context = nil
    end
  end
end

# this is a tracepoint that will output the path of all files loaded that contain the string "phlex"
# trace = TracePoint.new(:class) do |tp|
#   puts "Loaded: #{tp.path}" if tp.path.include?("phlex")
# end
# trace.enable
