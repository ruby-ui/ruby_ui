# frozen_string_literal: true

module Golden
  # The catalog of scenarios the golden suite renders. Structure only — the
  # scenarios themselves live in test/golden/scenarios.rb.
  module Catalog
    SNAPSHOT_ROOT = File.expand_path("snapshots", __dir__)
    LIB_ROOT = File.expand_path("../../lib/ruby_ui", __dir__)

    # `pending` holds a reason string when a scenario cannot be pinned by a
    # snapshot. A pending scenario is still declared, still rendered, and still
    # counts towards class coverage — it just has no recorded HTML. That keeps
    # the gap in the code rather than in someone's memory.
    Scenario = Struct.new(:component, :name, :block, :pending) do
      def slug
        "#{component}/#{name}"
      end

      def pinned?
        pending.nil?
      end

      def snapshot_path
        File.join(SNAPSHOT_ROOT, component, "#{name}.html")
      end

      def test_name
        :"test_#{component}__#{name}"
      end
    end

    class << self
      def scenarios
        @scenarios ||= []
      end

      def component(name, &)
        previous = @component
        @component = name.to_s
        instance_eval(&)
      ensure
        @component = previous
      end

      def scenario(name, pending: nil, &block)
        raise "scenario #{name.inspect} declared outside a component block" unless @component

        slug = "#{@component}/#{name}"
        raise "duplicate scenario #{slug}" if scenarios.any? { |existing| existing.slug == slug }

        scenarios << Scenario.new(@component, name.to_s, block, pending)
      end

      # Every directory under lib/ruby_ui/ is a component and must appear in the
      # catalog. `docs/` holds the documentation views that ship with the gem,
      # not components.
      def component_directories
        Dir.children(LIB_ROOT)
          .select { |entry| File.directory?(File.join(LIB_ROOT, entry)) }
          .reject { |entry| entry == "docs" }
          .sort
      end

      # Every RubyUI::Base subclass shipped by the gem. Non-Base classes in the
      # same directories (the DataTable pagination adapters, the Toast flash
      # helper module) emit no HTML and are covered by their own unit tests.
      def component_classes
        component_directories
          .flat_map { |directory| Dir.glob(File.join(LIB_ROOT, directory, "*.rb")) }
          .reject { |path| path.end_with?("_docs.rb") }
          .map { |path| constant_for(path) }
          .select { |constant| constant.is_a?(Class) && constant < RubyUI::Base }
          .map(&:name)
          .sort
      end

      private

      def constant_for(path)
        name = File.basename(path, ".rb").split("_").map(&:capitalize).join
        RubyUI.const_get(name)
      end
    end
  end
end
