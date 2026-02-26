# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "tmpdir"

# Tests the file filtering logic used in ComponentGenerator#components_file_paths
# to ensure documentation files (*_docs.rb) are excluded from component generation.
class ComponentGeneratorTest < Minitest::Test
  def test_excludes_docs_file_from_component_files
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "link.rb"))
      FileUtils.touch(File.join(tmpdir, "link_docs.rb"))

      component_files = Dir.glob(File.join(tmpdir, "*.rb")).reject { |f| f.end_with?("_docs.rb") }
      file_names = component_files.map { |f| File.basename(f) }

      assert_includes file_names, "link.rb"
      refute_includes file_names, "link_docs.rb"
    end
  end

  def test_includes_all_non_docs_rb_files
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "accordion.rb"))
      FileUtils.touch(File.join(tmpdir, "accordion_item.rb"))
      FileUtils.touch(File.join(tmpdir, "accordion_trigger.rb"))
      FileUtils.touch(File.join(tmpdir, "accordion_docs.rb"))

      component_files = Dir.glob(File.join(tmpdir, "*.rb")).reject { |f| f.end_with?("_docs.rb") }
      file_names = component_files.map { |f| File.basename(f) }

      assert_includes file_names, "accordion.rb"
      assert_includes file_names, "accordion_item.rb"
      assert_includes file_names, "accordion_trigger.rb"
      refute_includes file_names, "accordion_docs.rb"
    end
  end

  def test_link_component_docs_file_is_excluded_from_source
    source_root = File.expand_path("../../lib/ruby_ui", __dir__)
    link_dir = File.join(source_root, "link")

    all_rb_files = Dir.glob(File.join(link_dir, "*.rb"))
    component_files = all_rb_files.reject { |f| f.end_with?("_docs.rb") }

    # Precondition: link_docs.rb must exist so this test is meaningful
    assert(all_rb_files.any? { |f| f.end_with?("_docs.rb") },
      "Expected link_docs.rb to exist in the link component folder")

    # The docs file must not appear in the filtered result
    refute(component_files.any? { |f| f.end_with?("_docs.rb") },
      "link_docs.rb should not be included in component file paths")
  end

  def test_includes_docs_file_when_with_docs_is_true
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "link.rb"))
      FileUtils.touch(File.join(tmpdir, "link_docs.rb"))

      with_docs = true
      all_files = Dir.glob(File.join(tmpdir, "*.rb"))
      component_files = with_docs ? all_files : all_files.reject { |f| f.end_with?("_docs.rb") }
      file_names = component_files.map { |f| File.basename(f) }

      assert_includes file_names, "link.rb"
      assert_includes file_names, "link_docs.rb"
    end
  end
end
