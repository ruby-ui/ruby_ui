# frozen_string_literal: true

require "test_helper"

class LicenseTest < Minitest::Test
  GEM_ROOT = File.expand_path("..", __dir__)
  PERMISSION_SENTENCE = "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software."

  def test_license_carries_shadcn_mit_notice
    license = normalize(File.read(File.join(GEM_ROOT, "LICENSE.txt")))

    assert_includes license, "Copyright (c) 2023 shadcn"
    assert_operator license.scan(PERMISSION_SENTENCE).size, :>=, 2
  end

  def test_gemspec_ships_license
    spec = Dir.chdir(GEM_ROOT) { Gem::Specification.load("ruby_ui.gemspec") }

    assert_includes spec.files, "LICENSE.txt"
  end

  def test_readme_license_points_to_own_license
    readme = File.read(File.join(GEM_ROOT, "README.md"))
    section = readme[/^## License.*?(?=^---|^## |\z)/m]

    refute_nil section, "expected a '## License' section"
    assert_includes section, "(LICENSE.txt)"
    assert_match(/shadcn/i, section)
    refute_includes section, "github.com/shadcn/ui/blob/main/LICENSE.md"
  end

  private

  def normalize(text)
    text.gsub(/\s+/, " ")
  end
end
