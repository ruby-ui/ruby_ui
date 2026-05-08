# -*- encoding: utf-8 -*-
# stub: standard-custom 1.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "standard-custom".freeze
  s.version = "1.0.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/standardrb/standard-custom/blob/main/CHANGELOG.md", "default_lint_roller_plugin" => "Standard::Custom::Plugin", "homepage_uri" => "https://github.com/standardrb/standard-custom", "source_code_uri" => "https://github.com/standardrb/standard-custom" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Justin Searls".freeze]
  s.bindir = "exe".freeze
  s.date = "2023-07-13"
  s.email = ["searls@gmail.com".freeze]
  s.homepage = "https://github.com/standardrb/standard-custom".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.4.14".freeze
  s.summary = "Plugin containing implementations of custom cops that are bundled as defaults in Standard Ruby".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<lint_roller>.freeze, ["~> 1.0".freeze])
  s.add_runtime_dependency(%q<rubocop>.freeze, ["~> 1.50".freeze])
end
