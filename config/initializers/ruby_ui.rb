# frozen_string_literal: true

require "ruby_ui"

module RubyUI
  extend Phlex::Kit
end

# Allow using RubyUI instead RubyUi
Rails.autoloaders.main.inflector.inflect(
  "ruby_ui" => "RubyUI"
)

# The docs app has local RubyUI-only helpers/components under lib/ruby_ui/*.
# Collapse subdirectories so files like lib/ruby_ui/data_table/data_table.rb map
# to RubyUI::DataTable instead of RubyUI::DataTable::DataTable.
local_ruby_ui_path = Rails.root.join("lib/ruby_ui").to_s
Rails.autoloaders.main.collapse(
  Dir.glob("#{local_ruby_ui_path}/*").select { |p| File.directory?(p) }
)

# Autoload RubyUI components directly from the gem's lib/ruby_ui directory
# (the gem lives at ./gem in this monorepo, resolved via Bundler).
gem_ruby_ui_path = "#{Gem.loaded_specs["ruby_ui"].gem_dir}/lib/ruby_ui"

Rails.autoloaders.main.push_dir(gem_ruby_ui_path, namespace: RubyUI)
Rails.autoloaders.main.collapse(
  Dir.glob("#{gem_ruby_ui_path}/*").select { |p| File.directory?(p) && File.basename(p) != "docs" }
)

# The gem ships *_docs.rb files (Views::Docs::*) and a docs/ scaffolding folder
# (Docs::*). The Rails docs app has its own richer implementations under
# app/views/docs and app/components/docs, so we ignore the gem versions to
# avoid Zeitwerk namespace mismatches.
Rails.autoloaders.main.ignore("#{gem_ruby_ui_path}/docs")
Dir.glob("#{gem_ruby_ui_path}/**/*_docs.rb").each do |f|
  Rails.autoloaders.main.ignore(f)
end
