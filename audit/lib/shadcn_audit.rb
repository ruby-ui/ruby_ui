require "json"
require "pathname"

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
require "shadcn_audit/cli"
