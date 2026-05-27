# frozen_string_literal: true

require "ruby_ui/mcp/tools/base"

module RubyUI
  module MCP
    module Tools
      class GetAuditChecklist < Base
        CHECKLIST = [
          {check: "gem_in_gemfile", description: "`ruby_ui` gem present in Gemfile."},
          {check: "components_copied", description: "Component files exist under app/components/ruby_ui/<name>/."},
          {check: "stimulus_registered", description: "Stimulus controllers registered (where applicable)."},
          {check: "js_packages_installed", description: "JS packages from dependencies.yml present in package.json."},
          {check: "tailwind_content_paths", description: "Tailwind content config includes app/components/ruby_ui/**/*."},
          {check: "zeitwerk_loads", description: "Zeitwerk loads the RubyUI namespace without errors."},
          {check: "views_compile", description: "Generated Phlex views render without errors."}
        ].freeze

        def call(**)
          {checklist: CHECKLIST}
        end
      end
    end
  end
end
