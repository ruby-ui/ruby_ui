require_relative "lib/ruby_ui"

Gem::Specification.new do |s|
  s.name = "ruby_ui"
  s.version = RubyUI::VERSION
  s.summary = "RubyUI is a UI Component Library for Ruby developers."
  s.description = "Ruby UI is a UI Component Library for Ruby developers. Built on top of the Phlex Framework."
  s.authors = ["George Kettle"]
  s.email = "george.kettle@icloud.com"
  s.files = Dir["README.md", "LICENSE.txt", "lib/**/*"]
  s.require_path = "lib"
  s.homepage =
    "https://rubygems.org/gems/ruby_ui"
  s.license = "MIT"

  s.required_ruby_version = ">= 3.2"

  s.add_development_dependency "phlex", "~> 2.1", ">= 2.1.2"
  s.add_development_dependency "rouge", "~> 5.1.0"
  s.add_development_dependency "tailwind_merge", "~> 1.4"
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "standard", "~> 1.0"
  s.add_development_dependency "minitest", "~> 6.0"
  # Golden suite only: the HTML5-spec parser the snapshot comparison is built on.
  s.add_development_dependency "nokogiri", "~> 1.18"
  # 2.0 harness: the inline Rails application the tests boot, ReActionView's
  # handler (so ERB compiles through Herb as it will in a host app), and
  # phlex-rails so ERB fixtures can render components that are still Phlex
  # during the migration. phlex-rails leaves with the last Phlex component.
  s.add_development_dependency "railties", "~> 8.1"
  s.add_development_dependency "actionview", "~> 8.1"
  s.add_development_dependency "reactionview", "~> 0.4"
  s.add_development_dependency "phlex-rails", "~> 2.4"
end
