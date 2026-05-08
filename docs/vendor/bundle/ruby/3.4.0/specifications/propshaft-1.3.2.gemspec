# -*- encoding: utf-8 -*-
# stub: propshaft 1.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "propshaft".freeze
  s.version = "1.3.2".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "1980-01-02"
  s.email = "dhh@hey.com".freeze
  s.homepage = "https://github.com/rails/propshaft".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "4.0.3".freeze
  s.summary = "Deliver assets for Rails.".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<actionpack>.freeze, [">= 7.0.0".freeze])
  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 7.0.0".freeze])
  s.add_runtime_dependency(%q<rack>.freeze, [">= 0".freeze])
end
