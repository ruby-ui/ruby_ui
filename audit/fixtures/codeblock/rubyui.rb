# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/codeblock (strings in content.yml).
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
      div(class: "w-[32rem] p-6") do
        Codeblock(CODE, syntax: :plaintext)
      end
    end
  end
end
