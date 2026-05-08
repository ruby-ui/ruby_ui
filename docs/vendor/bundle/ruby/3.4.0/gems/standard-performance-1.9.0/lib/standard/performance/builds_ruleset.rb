require_relative "determines_yaml_path"
require_relative "loads_yaml_with_inheritance"

module Standard
  module Performance
    class BuildsRuleset
      def initialize
        @determines_yaml_path = DeterminesYamlPath.new
        @loads_yaml_with_inheritance = LoadsYamlWithInheritance.new
        @merges_upstream_metadata = LintRoller::Support::MergesUpstreamMetadata.new
      end

      def build(target_ruby_version)
        @merges_upstream_metadata.merge(
          @loads_yaml_with_inheritance.load(@determines_yaml_path.determine(target_ruby_version)),
          @loads_yaml_with_inheritance.load(Pathname.new(Gem.loaded_specs["rubocop-performance"].full_gem_path).join("config/default.yml"))
        )
      end
    end
  end
end
