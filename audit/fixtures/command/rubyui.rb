# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/command (strings in content.yml).
  class Command < Phlex::HTML
    include RubyUI

    def view_template
      CommandDialog do
        CommandDialogTrigger do
          Button(variant: :outline, data: {audit_trigger: true}) { "Search commands" }
        end
        CommandDialogContent do
          Command do
            CommandInput(placeholder: "Type a command or search...")
            CommandEmpty { "No results found." }
            CommandList do
              CommandGroup(title: "Suggestions") do
                CommandItem(value: "Calendar") { "Calendar" }
                CommandItem(value: "Calculator") { "Calculator" }
                CommandItem(value: "Settings") { "Settings" }
              end
            end
          end
        end
      end
    end
  end
end
