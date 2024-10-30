require_relative "lib/rbui/version"

Gem::Specification.new do |s|
  s.name = "ruby_ui"
  s.version = RBUI::VERSION
  s.summary = "RubyUI is a UI Component Library for Ruby developers."
  s.description = "Ruby UI is a UI Component Library for Ruby developers. Built on top of the Phlex Framework."
  s.authors = ["George Kettle"]
  s.email = "george.kettle@icloud.com"
  s.files = Dir["lib/**/*.rb", "tasks/**/*.rake"]
  s.require_path = "lib"
  s.homepage =
    "https://rubygems.org/gems/ruby_ui"
  s.license = "MIT"

  s.required_ruby_version = ">= 3.2"

  s.add_dependency "phlex", "~> 1.10"
  s.add_dependency "rouge", "~> 4.2.0"
  s.add_dependency "tailwind_merge", "~> 0.12"

  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "standard", "~> 1.0"
  s.add_development_dependency "minitest", "~> 5.0"
end
