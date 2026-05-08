require_relative "lib/mini_portile2/version"

Gem::Specification.new do |spec|
  spec.name = "mini_portile2"
  spec.version = MiniPortile::VERSION

  spec.authors = ["Luis Lavena", "Mike Dalessio", "Lars Kanis"]
  spec.email = "mike.dalessio@gmail.com"

  spec.summary = "Simple autoconf and cmake builder for developers"
  spec.description = <<~TEXT
    Simple autoconf and cmake builder for developers. It provides a standard way to compile against
    dependency libraries without requiring system-wide installation. It also simplifies
    vendoring and cross-compilation by providing a consistent build interface.
  TEXT

  spec.homepage = "https://github.com/flavorjones/mini_portile"
  spec.licenses = ["MIT"]

  begin
    spec.files = `git ls-files -z`.split("\x0")
  rescue Exception => e
    warn "WARNING: could not set spec.files: #{e.class}: #{e}"
  end

  # omit the `examples` directory from the gem, because it's large and
  # not necessary to be packaged in the gem.
  example_files = spec.files.grep(%r{^examples/})
  spec.files -= example_files

  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features|examples)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.0"

  spec.metadata["changelog_uri"] = spec.homepage + "/blob/main/CHANGELOG.md"
end
