# frozen_string_literal: true

module RubyUI
  extend Phlex::Kit
end

# Allow using RubyUI instead RubyUi
Rails.autoloaders.main.inflector.inflect(
  "ruby_ui" => "RubyUI"
)

# Allow using RubyUI::ComponentName instead Components::RubyUI::ComponentName
Rails.autoloaders.main.push_dir(
  "#{Rails.root}/app/components/ruby_ui", namespace: RubyUI
)

# Allow using RubyUI::ComponentName instead RubyUI::ComponentName::ComponentName
Rails.autoloaders.main.collapse(Rails.root.join("app/components/ruby_ui/*"))
