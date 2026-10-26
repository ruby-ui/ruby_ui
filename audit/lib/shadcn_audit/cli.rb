require "optparse"

module ShadcnAudit
  # Every subcommand prints exactly one JSON object. Later tasks register
  # more handlers in COMMANDS (name => callable(args, out:)).
  class CLI
    class UnknownCommand < StandardError; end

    COMMANDS = {
      "workspace" => ->(args, out:) { workspace(args, out: out) }
    }

    def self.start(argv, out: $stdout)
      name, *args = argv
      handler = COMMANDS[name] or raise UnknownCommand, "unknown subcommand: #{name.inspect}"
      out.puts JSON.generate(handler.call(args, out: out))
    end

    def self.workspace(args, out:)
      sha = nil
      OptionParser.new { |o| o.on("--sha SHA") { |v| sha = v } }.parse!(args)
      Workspace.new(shell: Shell.new, dir: ShadcnAudit.workspace_dir).sync(sha: sha)
    end
  end
end
