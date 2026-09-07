# frozen_string_literal: true

# The gate's catalog: the same component/name keys as gem/test/golden/
# scenarios.rb, each backed by a view under app/views/gate/ written the way a
# 2.0 user would write it, and compared against the gem's recorded 1.6 snapshot.
module Gate
  module Scenarios
    Scenario = Struct.new(:component, :name, :snapshot) do
      def slug = "#{component}/#{name}"

      def template = "gate/#{component}_#{name}"

      def snapshot_path = GEM_ROOT.join("test/golden/snapshots/#{snapshot}.html").to_s
    end

    class << self
      def all
        @all ||= []
      end

      def component(name, &)
        @component = name.to_s
        instance_eval(&)
      ensure
        @component = nil
      end

      def scenario(name, snapshot: nil)
        all << Scenario.new(@component, name.to_s, snapshot || "#{@component}/#{name}")
      end
    end
  end
end

# Phase 1 (plan §4): Dialog — 8 classes in dialog/ plus Button.
Gate::Scenarios.component "dialog" do
  scenario "default"
  %w[sm md lg xl].each { |size| scenario "content_#{size}" }
  scenario "open"
end

# Runner self-check (Phase 0 acceptance a): the view is the literal
# dialog/default snapshot, so it can only fail if the runner itself is wrong.
Gate::Scenarios.component "sentinel" do
  scenario "dialog_default", snapshot: "dialog/default"
end
