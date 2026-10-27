require "json"
require "pathname"
require "fileutils"

module ShadcnAudit
  ROOT = Pathname.new(File.expand_path("../../..", __FILE__))

  def self.root = ROOT

  def self.workspace_dir = root.join(".shadcn-audit")
end

require "shadcn_audit/shell"
require "shadcn_audit/workspace"
require "shadcn_audit/component_map"
require "shadcn_audit/divergences"
require "shadcn_audit/target"
require "shadcn_audit/reference"
require "shadcn_audit/theme"
require "shadcn_audit/sandbox"
require "shadcn_audit/rubyui_preview"
require "shadcn_audit/report"
require "shadcn_audit/renderers/terminal"
require "shadcn_audit/renderers/markdown"
require "shadcn_audit/renderers/html"
require "shadcn_audit/pr_comment"
require "shadcn_audit/cli"
