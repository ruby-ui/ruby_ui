require_relative "builds_ruleset"

module Standard::Performance
  class Plugin < LintRoller::Plugin
    def initialize(config)
      @config = config
      @builds_ruleset = BuildsRuleset.new
    end

    def about
      LintRoller::About.new(
        name: "standard-performance",
        version: VERSION,
        homepage: "https://github.com/testdouble/standard-performance",
        description: "Configuration for rubocop-performance's rules"
      )
    end

    def supported?(context)
      true
    end

    def rules(context)
      trick_rubocop_into_thinking_we_required_rubocop_performance!

      LintRoller::Rules.new(
        type: :object,
        config_format: :rubocop,
        value: @builds_ruleset.build(context.target_ruby_version)
      )
    end

    private

    # This is not fantastic.
    #
    # When you `require "rubocop-performance"`, it will not only load the cops,
    # but it will also monkey-patch RuboCop's default_configuration, which is
    # something that can't be undone for the lifetime of the process.
    #
    # See: https://github.com/rubocop/rubocop-performance/commit/587050a8c0ec6d2fa64f5be970425a7f4c5d779b
    #
    # As an alternative, standard-performance loads the cops directly, and then
    # simply tells the RuboCop config loader that it's been loaded. This is
    # taking advantage of a private API of an `attr_reader` that probably wasn't
    # meant to be mutated externally, but it's better than the `Inject` monkey
    # patching that rubocop-performance does (and many other RuboCop plugins do)
    def trick_rubocop_into_thinking_we_required_rubocop_performance!
      require "rubocop"
      require "rubocop/cop/performance_cops"
      RuboCop::ConfigLoader.default_configuration.loaded_features.add("rubocop-performance")
    end
  end
end
