# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/codeblock (strings in content.yml): a
  # floating copy button, a header + footer, and numbered diff lines.
  class Codeblock < Phlex::HTML
    include RubyUI

    CODE = <<~CODE
      $ pnpm add ai zod
      dependencies:
      + ai 6.0.12
      + zod 4.1.12
      Done in 2.8s
    CODE

    def view_template
      div(class: "flex w-[32rem] flex-col gap-4 p-6") do
        Codeblock(CODE, syntax: :plaintext, data: {audit_trigger: true})
        Codeblock do
          CodeblockHeader do
            CodeblockTitle { "install.sh" }
            CodeblockActions { CodeblockCopyButton(value: CODE) }
          end
          CodeblockContent(CODE, syntax: :plaintext)
          CodeblockFooter { "Runs in the project root." }
        end
        Codeblock do
          CodeblockContent(line_numbers: true) do
            CodeblockLine(variant: :removed) { "const answer = 41" }
            CodeblockLine(variant: :added) { "const answer = 42" }
            CodeblockLine()
            CodeblockLine(variant: :highlighted) { "console.log(answer)" }
          end
        end
      end
    end
  end
end
