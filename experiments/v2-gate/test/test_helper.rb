ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# The ruler is the gem's, read in place and never copied: gem/test/golden/
# canonical_html.rb (nokogiri only) and the recorded 1.6 snapshots.
GEM_ROOT = Rails.root.join("../../gem").expand_path
require GEM_ROOT.join("test/golden/canonical_html").to_s
require_relative "golden/harness"
require_relative "golden/scenarios"

module Gate
  # "herb" or "erubi": the Gemfile this process booted with (config/boot.rb).
  LANE = File.basename(ENV.fetch("BUNDLE_GEMFILE")).delete_prefix("Gemfile.")

  def self.lane = LANE

  # Gate lanes: herb (ReActionView + herb 0.10.3) and erubi (control).
  def self.herb? = LANE == "herb"

  # Spike lane, not a gate lane: Rails' own Herb handler + herb main's
  # ComponentTags::Visitor (Gemfile.tags, design/v2/05-decisions.md).
  def self.tags? = LANE == "tags"

  # Any lane whose templates go through Herb::Engine (parser errors raise).
  def self.compiles_with_herb? = herb? || tags?

  # The 2.0 equivalent of the gem's `phlex { ... }` helper: a view rendered with
  # no request and no layout, generated ids pinned, through the gate controller.
  #
  # The template is compiled by an unpinned render first. The pin is for ids a
  # *component* mints while rendering; a compiler may draw from SecureRandom
  # while compiling (herb main does, HERB_FINDINGS.md row 17), and that must not
  # shift the counter the 1.6 snapshots were recorded against.
  def self.render(template, **options)
    GateController.render(template: template, layout: false, **options)
    Harness.render { GateController.render(template: template, layout: false, **options) }
  end

  def self.canonical(template, **options)
    Golden::CanonicalHtml.call(render(template, **options))
  end
end

# Probes: throwaway components and views that exercise the layer, kept out of
# app/. Their directories become view paths (so sidecar templates resolve) and
# the component files are required directly — no Zeitwerk root for test code.
ActionController::Base.prepend_view_path Rails.root.join("test/probes/views")
ActionController::Base.prepend_view_path Rails.root.join("test/probes/components")
Dir[Rails.root.join("test/probes/components/probes/*.rb")].sort.each { |file| require file }
GateController.helper Probes::Issue57Helper

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
  end
end
