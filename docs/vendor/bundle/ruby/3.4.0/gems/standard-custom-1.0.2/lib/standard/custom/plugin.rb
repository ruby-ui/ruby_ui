module Standard::Custom
  class Plugin < LintRoller::Plugin
    def initialize(config)
      @config = config
    end

    def about
      LintRoller::About.new(
        name: "standard-custom",
        version: VERSION,
        homepage: "https://github.com/testdouble/standard-custom",
        description: "Custom rules defined by the Standard Ruby project as part of the default ruleset"
      )
    end

    def supported?(context)
      true
    end

    def rules(context)
      LintRoller::Rules.new(
        type: :path,
        config_format: :rubocop,
        value: Pathname.new(__dir__).join("../../../config/base.yml")
      )
    end
  end
end
