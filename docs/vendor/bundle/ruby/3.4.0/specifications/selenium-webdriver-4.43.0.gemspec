# -*- encoding: utf-8 -*-
# stub: selenium-webdriver 4.43.0 ruby lib

Gem::Specification.new do |s|
  s.name = "selenium-webdriver".freeze
  s.version = "4.43.0".freeze

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/SeleniumHQ/selenium/blob/trunk/rb/CHANGES", "documentation_uri" => "https://www.selenium.dev/documentation/?tab=ruby", "funding_uri" => "https://github.com/sponsors/SeleniumHQ", "github_repo" => "ssh://github.com/SeleniumHQ/selenium", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/SeleniumHQ/selenium/tree/trunk/rb" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Alex Rodionov".freeze, "Titus Fortner".freeze, "Thomas Walpole".freeze]
  s.date = "2026-04-10"
  s.description = "    Selenium implements the W3C WebDriver protocol to automate popular browsers.\n    It aims to mimic the behaviour of a real user as it interacts with the application's HTML.\n    It's primarily intended for web application testing, but any web-based task can automated.\n".freeze
  s.email = ["p0deje@gmail.com".freeze, "titusfortner@gmail.com".freeze, "twalpole@gmail.com".freeze]
  s.homepage = "https://selenium.dev".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.2".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Selenium is a browser automation tool for automated testing of webapps and more".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<base64>.freeze, ["~> 0.2".freeze])
  s.add_runtime_dependency(%q<logger>.freeze, ["~> 1.4".freeze])
  s.add_runtime_dependency(%q<rexml>.freeze, ["~> 3.2".freeze, ">= 3.2.5".freeze])
  s.add_runtime_dependency(%q<rubyzip>.freeze, [">= 1.2.2".freeze, "< 4.0".freeze])
  s.add_runtime_dependency(%q<websocket>.freeze, ["~> 1.0".freeze])
  s.add_development_dependency(%q<git>.freeze, ["~> 1.19".freeze])
  s.add_development_dependency(%q<rack>.freeze, ["~> 2.0".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0".freeze])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.75".freeze])
  s.add_development_dependency(%q<rubocop-performance>.freeze, ["~> 1.25".freeze])
  s.add_development_dependency(%q<rubocop-rake>.freeze, ["~> 0.7".freeze])
  s.add_development_dependency(%q<rubocop-rspec>.freeze, ["~> 3.5".freeze])
  s.add_development_dependency(%q<webmock>.freeze, ["~> 3.5".freeze])
  s.add_development_dependency(%q<webrick>.freeze, ["~> 1.7".freeze])
  s.add_development_dependency(%q<yard>.freeze, ["~> 0.9.11".freeze, ">= 0.9.36".freeze])
end
