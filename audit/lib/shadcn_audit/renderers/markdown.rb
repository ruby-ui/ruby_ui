require "shadcn_audit/renderers/terminal"

module ShadcnAudit
  module Renderers
    # The PR comment: marker, SHA table, then the checklist in a code fence.
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
          | PR | #{h["pr"] ? "##{h["pr"]}" : "-"} |
          | RubyUI base | `#{Terminal.short(h["base_sha"])}` |
          | RubyUI head | `#{Terminal.short(h["head_sha"])}` |
          | shadcn | `#{Terminal.short(h["shadcn_sha"])}` |

          #{fence}
          #{body}
          #{fence}
        MD
      end
    end
  end
end
