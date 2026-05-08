# frozen_string_literal: true

require_relative "lib/tailwind_merge/version"

Gem::Specification.new do |spec|
  spec.name = "tailwind_merge"
  spec.version = TailwindMerge::VERSION
  spec.summary = "Utility function to efficiently merge Tailwind CSS classes without style conflicts."
  spec.authors = ["Garen J. Torikian"]
  spec.email = ["gjtorikian@gmail.com"]
  spec.license = "MIT"

  github_root_uri = "https://github.com/gjtorikian/tailwind_merge"
  spec.homepage = "#{github_root_uri}/tree/v#{spec.version}"
  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "#{github_root_uri}/blob/v#{spec.version}/CHANGELOG.md",
    "bug_tracker_uri" => "#{github_root_uri}/issues",
    "documentation_uri" => "https://rubydoc.info/gems/#{spec.name}/#{spec.version}",
    "funding_uri" => "https://github.com/sponsors/gjtorikian",
    "rubygems_mfa_required" => "true",
  }

  spec.required_ruby_version = [">= 3.2"]

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    %x(git ls-files -z).split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("sin_lru_redux", "~> 2.5")

  spec.add_development_dependency("minitest", "~> 6.0")
  spec.add_development_dependency("minitest-focus", "~> 1.1")
end
