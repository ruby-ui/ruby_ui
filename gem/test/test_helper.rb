# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ruby_ui"
require "phlex"
require "json"
require "securerandom"
require "rails"
require "action_controller/railtie"
require "reactionview"
require "phlex-rails"
require "minitest/autorun"

module RubyUI
  extend Phlex::Kit

  Dir.glob("lib/ruby_ui/**/*.rb").reject { |f| f.include?("/docs/") || f.end_with?("_docs.rb") }.map do |path|
    class_name = path.split("/").last.delete_suffix(".rb").split("_").map(&:capitalize).join.to_sym

    autoload class_name, path
  end

  # The smallest Rails application that gives ReActionView what it reads:
  # `Rails.root` (a template under it is "local", so a Herb rejection raises
  # instead of falling back to Erubi), `Rails.env` and `Rails.logger`. No app/
  # directory, no routes, no database — an object, so the gem's tests compile
  # ERB exactly as a host application will.
  class TestApp < Rails::Application
    ROOT = File.expand_path("..", __dir__)
    PROBE_VIEWS = File.join(ROOT, "test/probes/views")

    config.root = ROOT
    config.eager_load = false
    config.secret_key_base = "ruby_ui-test"
    config.logger = Logger.new(IO::NULL)
    config.hosts.clear

    class << self
      # One compiled-template cache per process, as in an app; a fresh view
      # context per call, with the given view paths.
      def view(*paths)
        view_class.with_view_paths(paths.empty? ? [PROBE_VIEWS] : paths)
      end

      private

      def view_class
        @view_class ||= ActionView::Base.with_empty_template_cache
      end
    end
  end
end

ReActionView.config.intercept_erb = true
ReActionView.config.validation_mode = :raise
ReActionView.config.debug_mode = false
Rails.application.initialize!

# component_roots= is a module method, not a constant: the autoload above does
# not reach it, so the file is required outright.
require "ruby_ui/component"

# Two component roots: the gem's own components, and the test-only probes.
# A class's sidecar is looked up under the root that contains the class file.
RubyUI.component_roots = [File.join(RubyUI::TestApp::ROOT, "lib"), File.join(RubyUI::TestApp::ROOT, "test/probes")]
Dir.glob(File.join(RubyUI::TestApp::ROOT, "test/probes/ruby_ui/**/*.rb")).sort.each { |probe| require probe }

class ComponentTest < Minitest::Test
  def render(component, &)
    component.call(&)
  end

  def phlex(&)
    render Phlex::HTML.new, &
  end

  def render_erb(template)
    RubyUI::TestApp.view.render(template: template)
  end
end
