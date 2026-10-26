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
      "theme" => ->(args, out:) { theme(args, out: out) },
      "sandbox" => ->(args, out:) { sandbox(args, out: out) },
      "preview" => ->(args, out:) { preview(args, out: out) },
      "render" => ->(args, out:) { render(args, out: out) },
      "comment" => ->(args, out:) { comment(args, out: out) }
    }

    # Failures the CLI reports as {"error": ...} with exit status 1 instead
    # of a backtrace, so callers always get one JSON object.
    ERRORS = [UnknownCommand, Shell::Error, ConfigError, ReportError, ArgumentError,
      Errno::ENOENT, JSON::ParserError, OptionParser::ParseError].freeze

    # Entry point for exe/shadcn-audit; returns the process exit status.
    def self.run(argv, out: $stdout)
      start(argv, out: out)
      0
    rescue *ERRORS => e
      out.puts JSON.generate("error" => e.message)
      1
    end

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

    def self.sandbox(args, out:)
      shell = Shell.new
      shadcn_sha = Workspace.new(shell: shell, dir: ShadcnAudit.workspace_dir).current_sha
      Sandbox.new(shell: shell, dir: ShadcnAudit.workspace_dir, shadcn_sha: shadcn_sha).prepare
    end

    def self.preview(args, out:)
      sha = args.first or raise ArgumentError, "usage: preview <sha>"
      RubyuiPreview.new(shell: Shell.new, dir: ShadcnAudit.workspace_dir).prepare(sha)
    end

    # The terminal text is the payload so the one-JSON-object contract holds.
    def self.render(args, out:)
      html = false
      parser = OptionParser.new { |o| o.on("--html") { html = true } }
      path = parser.parse!(args).first or raise ArgumentError, "usage: render <report.json> [--html]"
      report = Report.load(path)
      {
        "text" => Renderers::Terminal.render(report),
        "html" => html ? Renderers::Html.render(report, out_dir: File.dirname(path)) : nil
      }
    end

    # Without --post this only returns the body; --post is the one write path.
    def self.comment(args, out:, shell: Shell.new)
      post = false
      parser = OptionParser.new { |o| o.on("--post") { post = true } }
      path = parser.parse!(args).first or raise ArgumentError, "usage: comment <report.json> [--post]"
      report = Report.load(path)
      body = Renderers::Markdown.render(report)
      return {"posted" => false, "body" => body} unless post

      pr = report.target["pr"] or raise ArgumentError, "report target is not a PR"
      result = PrComment.new(shell: shell)
        .upsert(pr: pr, body: body, expected_head_sha: report.target["head_sha"])
      result.merge("posted" => result["action"] != "refused")
    end

    def self.workspace(args, out:)
      sha = nil
      OptionParser.new { |o| o.on("--sha SHA") { |v| sha = v } }.parse!(args)
      Workspace.new(shell: Shell.new, dir: ShadcnAudit.workspace_dir).sync(sha: sha)
    end
  end
end
