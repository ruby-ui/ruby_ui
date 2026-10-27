require "shadcn_audit/renderers/terminal"

module ShadcnAudit
  module Renderers
    # The PR comment: marker, SHA table (full SHAs, so they link and pin
    # exactly; the terminal shortens them), then the checklist in a code fence.
    module Markdown
      MARKER = "<!-- shadcn-audit -->".freeze

      def self.render(report)
        h = report.header
        body = Terminal.body(report)
        fence = "`" * [3, body.scan(/`+/).map(&:size).max.to_i + 1].max
        <<~MD
          #{MARKER}
          ## shadcn audit

          | | |
          | --- | --- |
          | Repo | `#{h["repo"]}` |
          | PR | #{h["pr"] ? "##{h["pr"]}" : "-"} |
          | RubyUI base | `#{h["base_sha"]}` |
          | RubyUI head | `#{h["head_sha"]}` |
          | shadcn | `#{h["shadcn_sha"]}` |

          #{fence}
          #{body}
          #{fence}
        MD
      end
    end
  end
end
