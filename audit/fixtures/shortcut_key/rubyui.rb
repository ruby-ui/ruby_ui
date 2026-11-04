# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/shortcut_key (strings in content.yml).
  class ShortcutKey < Phlex::HTML
    include RubyUI

    def view_template
      div(class: "flex flex-col items-start gap-4") do
        div(class: "flex items-center gap-2") do
          ShortcutKey { "Ctrl" }
          ShortcutKey { "⌘K" }
          ShortcutKey(data: {audit_trigger: true}) { "Ctrl + B" }
        end
        ShortcutKeyGroup do
          ShortcutKey { "Ctrl" }
          ShortcutKey { "Shift" }
          ShortcutKey { "P" }
        end
      end
    end
  end
end
