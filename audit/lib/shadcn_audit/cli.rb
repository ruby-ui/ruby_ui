require "optparse"

module ShadcnAudit
  # Every subcommand prints exactly one JSON object. Later tasks register
  # more handlers in COMMANDS (name => callable(args, out:)).
  class CLI
    class UnknownCommand < StandardError; end

    COMMANDS = {
      "workspace" => ->(args, out:) { workspace(args, out: out) },
      "map" => ->(args, out:) { map(args, out: out) },
      "divergences" => ->(args, out:) { divergences(args, out: out) },
      "target" => ->(args, out:) { target(args, out: out) },
      "reference" => ->(args, out:) { reference(args, out: out) },
      "theme" => ->(args, out:) { theme(args, out: out) }
    }

    def self.start(argv, out: $stdout)
      name, *args = argv
      handler = COMMANDS[name] or raise UnknownCommand, "unknown subcommand: #{name.inspect}"
      out.puts JSON.generate(handler.call(args, out: out))
    end

    def self.map(args, out:)
      folder = args.first or raise ArgumentError, "usage: map <folder>"
      component_map = ComponentMap.load(ShadcnAudit.root.join("audit/component_map.yml"))
      component_map.entry(folder) || {"missing" => true, "suggestion" => component_map.suggest_entry(folder)}
    end

    def self.divergences(args, out:)
      folder = args.first or raise ArgumentError, "usage: divergences <folder>"
      registry = Divergences.load(ShadcnAudit.root.join("audit/divergences.yml"))
      {"divergences" => registry.for_component(folder)}
    end

    def self.target(args, out:)
      arg = args.first or raise ArgumentError, "usage: target <pr-number|branch|component>"
      component_map = ComponentMap.load(ShadcnAudit.root.join("audit/component_map.yml"))
      Target.resolve(arg, shell: Shell.new, map: component_map)
    end

    def self.reference(args, out:)
      name = args.first or raise ArgumentError, "usage: reference <shadcn_name>"
      registry_dir = ShadcnAudit.workspace_dir.join("ui/apps/v4/registry")
      Reference.new(registry_dir: registry_dir).for(name)
    end

    def self.theme(args, out:)
      checkout = ShadcnAudit.root
      OptionParser.new { |o| o.on("--checkout DIR") { |v| checkout = Pathname.new(v) } }.parse!(args)
      Theme.compare(
        themes_ts: ShadcnAudit.workspace_dir.join("ui/apps/v4/registry/themes.ts"),
        rubyui_css: checkout.join("docs/app/assets/stylesheets/application.tailwind.css")
      )
    end

    def self.workspace(args, out:)
      sha = nil
      OptionParser.new { |o| o.on("--sha SHA") { |v| sha = v } }.parse!(args)
      Workspace.new(shell: Shell.new, dir: ShadcnAudit.workspace_dir).sync(sha: sha)
    end
  end
end
