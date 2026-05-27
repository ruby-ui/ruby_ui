# frozen_string_literal: true

require "json"

module RubyUI
  module MCP
    class Registry
      NAME_REGEX = /\A[A-Z][A-Za-z0-9]*\z/

      def self.load_default
        path = ENV["RUBY_UI_MCP_REGISTRY"] || default_path
        load(path)
      end

      def self.default_path
        File.expand_path("../../../data/registry.json", __dir__)
      end

      def self.load(path)
        raw = JSON.parse(File.read(path), symbolize_names: true)
        new(raw)
      end

      attr_reader :version

      def initialize(raw)
        @version = raw[:version]
        @components = raw[:components] || {}
      end

      def list
        @components.values.map { |c| {name: c[:name], description: c[:description]} }
      end

      def find(name)
        key = name.to_s.downcase.to_sym
        @components[key]
      end

      def search(query, limit: 10)
        q = query.to_s.downcase
        scored = @components.values.map do |c|
          haystack = "#{c[:name]} #{c[:description]} #{c[:docs_markdown]}".downcase
          score = haystack.include?(q) ? haystack.scan(q).length : 0
          [c, score]
        end
        scored.select { |_, s| s > 0 }
          .sort_by { |_, s| -s }
          .first(limit)
          .map { |c, s| {name: c[:name], description: c[:description], score: s} }
      end

      def partition_names(names)
        known_set = @components.values.map { |c| c[:name] }.to_set
        names.partition { |n| NAME_REGEX.match?(n) && known_set.include?(n) }
      end
    end
  end
end
