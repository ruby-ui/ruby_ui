# frozen_string_literal: true

require "test_helper"
require "rubygems/package"
require "tmpdir"

class GemspecTest < Minitest::Test
  GEM_ROOT = File.expand_path("..", __dir__)

  def test_packaged_files_match_allowlist
    files = build_and_list_files

    refute_empty files, "expected the .gem to ship some files"

    offenders = files.reject { |f| allowed?(f) }
    assert_empty offenders, <<~MSG
      ruby_ui.gemspec packaged unexpected files. The gemspec's
      s.files allowlist must keep these out of the published gem
      (e.g. files from docs/, test/, .github/, Gemfile, etc.):

        #{offenders.join("\n  ")}
    MSG
  end

  def test_includes_readme_and_license_and_lib
    files = build_and_list_files

    assert_includes files, "README.md"
    assert_includes files, "LICENSE.txt"
    assert files.any? { |f| f.start_with?("lib/") }, "expected lib/ files in the gem"
  end

  private

  def allowed?(path)
    path == "README.md" || path == "LICENSE.txt" || path.start_with?("lib/")
  end

  def build_and_list_files
    Dir.mktmpdir do |tmpdir|
      gem_path = File.join(tmpdir, "ruby_ui.gem")
      Dir.chdir(GEM_ROOT) do
        output = `gem build ruby_ui.gemspec --output #{gem_path} 2>&1`
        raise "gem build failed:\n#{output}" unless $?.success?
      end
      Gem::Package.new(gem_path).map { |entry| entry.full_name }
    end
  end
end
