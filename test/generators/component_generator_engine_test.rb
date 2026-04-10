# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "tmpdir"
require_relative "../../lib/generators/ruby_ui/engine_utils"
require "ruby_ui/herb/phlex_generator"

# Tests the --engine flag logic for ComponentGenerator.
#
# New convention (post-full-migration):
#   component.rb         — plain Ruby class (ComponentBase, no Phlex)
#   component.html.erb   — Herb template (source of truth)
#   component_docs.html.erb — ERB docs (replaces _docs.rb)
#
# Engines:
#   --engine=phlex (default): copies .rb files only (excludes .html.erb, _docs files)
#   --engine=erb:  copies .rb files + .html.erb templates
#   --engine=herb: same files as erb (signals consumer to install herb gem)
class ComponentGeneratorEngineTest < Minitest::Test
  EngineUtils = RubyUI::Generators::EngineUtils

  # ── Herb template detection ──────────────────────────────────

  def test_detects_herb_template_when_html_erb_present
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "button.rb"))
      File.write(File.join(tmpdir, "button.html.erb"), "<button><%= yield %></button>")

      assert EngineUtils.herb_component?(tmpdir)
    end
  end

  def test_no_herb_template_for_rb_only_component
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "legacy.rb"))

      refute EngineUtils.herb_component?(tmpdir)
    end
  end

  def test_herb_template_paths_returns_html_erb_files
    Dir.mktmpdir do |tmpdir|
      File.write(File.join(tmpdir, "button.html.erb"), "<button/>")
      File.write(File.join(tmpdir, "button_docs.html.erb"), "<%= render Button.new %>")

      paths = EngineUtils.herb_template_paths(tmpdir)
      names = paths.map { |f| File.basename(f) }

      assert_includes names, "button.html.erb"
      assert_includes names, "button_docs.html.erb"
    end
  end

  def test_herb_template_paths_empty_for_rb_only
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "link.rb"))

      assert_empty EngineUtils.herb_template_paths(tmpdir)
    end
  end

  # ── Phlex engine file selection (default) ────────────────────

  def test_phlex_engine_returns_rb_files_only
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "button.rb"))
      File.write(File.join(tmpdir, "button.html.erb"), "<button/>")
      File.write(File.join(tmpdir, "button_docs.html.erb"), "docs")

      files = EngineUtils.phlex_component_files(tmpdir)
      names = files.map { |f| File.basename(f) }

      assert_includes names, "button.rb"
      refute_includes names, "button.html.erb"
      refute_includes names, "button_docs.html.erb"
    end
  end

  def test_phlex_engine_excludes_docs_rb
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "button.rb"))
      FileUtils.touch(File.join(tmpdir, "button_docs.rb"))

      files = EngineUtils.phlex_component_files(tmpdir)
      names = files.map { |f| File.basename(f) }

      assert_includes names, "button.rb"
      refute_includes names, "button_docs.rb"
    end
  end

  def test_phlex_engine_includes_docs_rb_with_with_docs
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "button.rb"))
      FileUtils.touch(File.join(tmpdir, "button_docs.rb"))

      files = EngineUtils.phlex_component_files(tmpdir, with_docs: true)
      names = files.map { |f| File.basename(f) }

      assert_includes names, "button.rb"
      assert_includes names, "button_docs.rb"
    end
  end

  def test_phlex_engine_copies_all_rb_for_multi_file_component
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "accordion.rb"))
      FileUtils.touch(File.join(tmpdir, "accordion_item.rb"))
      FileUtils.touch(File.join(tmpdir, "accordion_trigger.rb"))

      files = EngineUtils.phlex_component_files(tmpdir)
      names = files.map { |f| File.basename(f) }

      assert_includes names, "accordion.rb"
      assert_includes names, "accordion_item.rb"
      assert_includes names, "accordion_trigger.rb"
    end
  end

  # ── ERB engine file selection ─────────────────────────────────

  def test_erb_engine_returns_rb_and_template
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "button.rb"))
      File.write(File.join(tmpdir, "button.html.erb"), "<button/>")
      File.write(File.join(tmpdir, "button_docs.html.erb"), "docs")

      files = EngineUtils.erb_component_files(tmpdir)
      names = files.map { |f| File.basename(f) }

      assert_includes names, "button.rb"
      assert_includes names, "button.html.erb"
      refute_includes names, "button_docs.html.erb"
    end
  end

  def test_erb_engine_excludes_docs_html_erb_by_default
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "button.rb"))
      File.write(File.join(tmpdir, "button.html.erb"), "<button/>")
      File.write(File.join(tmpdir, "button_docs.html.erb"), "docs")

      files = EngineUtils.erb_component_files(tmpdir, with_docs: false)
      names = files.map { |f| File.basename(f) }

      refute_includes names, "button_docs.html.erb"
    end
  end

  def test_erb_engine_includes_docs_html_erb_with_with_docs
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "button.rb"))
      File.write(File.join(tmpdir, "button.html.erb"), "<button/>")
      File.write(File.join(tmpdir, "button_docs.html.erb"), "docs")

      files = EngineUtils.erb_component_files(tmpdir, with_docs: true)
      names = files.map { |f| File.basename(f) }

      assert_includes names, "button_docs.html.erb"
    end
  end

  def test_erb_engine_falls_back_to_phlex_for_no_template
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "legacy.rb"))
      FileUtils.touch(File.join(tmpdir, "legacy_item.rb"))

      files = EngineUtils.erb_component_files(tmpdir)
      names = files.map { |f| File.basename(f) }

      assert_includes names, "legacy.rb"
      assert_includes names, "legacy_item.rb"
    end
  end

  # ── component_files_for_engine dispatch ──────────────────────

  def test_dispatch_phlex_engine
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "button.rb"))
      File.write(File.join(tmpdir, "button.html.erb"), "<button/>")

      files = EngineUtils.component_files_for_engine(tmpdir, engine: "phlex")
      names = files.map { |f| File.basename(f) }

      assert_includes names, "button.rb"
      refute_includes names, "button.html.erb"
    end
  end

  def test_dispatch_erb_engine
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "button.rb"))
      File.write(File.join(tmpdir, "button.html.erb"), "<button/>")

      files = EngineUtils.component_files_for_engine(tmpdir, engine: "erb")
      names = files.map { |f| File.basename(f) }

      assert_includes names, "button.rb"
      assert_includes names, "button.html.erb"
    end
  end

  def test_dispatch_herb_engine_same_as_erb
    Dir.mktmpdir do |tmpdir|
      FileUtils.touch(File.join(tmpdir, "button.rb"))
      File.write(File.join(tmpdir, "button.html.erb"), "<button/>")

      erb_files = EngineUtils.component_files_for_engine(tmpdir, engine: "erb")
      herb_files = EngineUtils.component_files_for_engine(tmpdir, engine: "herb")

      assert_equal erb_files.map { |f| File.basename(f) }.sort,
        herb_files.map { |f| File.basename(f) }.sort
    end
  end

  # ── Real component source directory ──────────────────────────

  def test_button_component_has_herb_template
    button_dir = File.join(source_root, "button")
    assert EngineUtils.herb_component?(button_dir), "Button should have a herb template"
  end

  def test_button_phlex_engine_returns_rb_file
    button_dir = File.join(source_root, "button")
    files = EngineUtils.phlex_component_files(button_dir)
    names = files.map { |f| File.basename(f) }

    assert_includes names, "button.rb"
    refute_includes names, "button.html.erb"
    refute_includes names, "button_docs.html.erb"
  end

  def test_button_erb_engine_returns_rb_and_template
    button_dir = File.join(source_root, "button")
    files = EngineUtils.erb_component_files(button_dir)
    names = files.map { |f| File.basename(f) }

    assert_includes names, "button.rb"
    assert_includes names, "button.html.erb"
    refute_includes names, "button_docs.html.erb"
  end

  def test_accordion_component_has_herb_template
    accordion_dir = File.join(source_root, "accordion")
    assert EngineUtils.herb_component?(accordion_dir)
  end

  # ── Phlex visitor generation ─────────────────────────────────

  def test_visitor_generates_phlex_from_button_template
    template = File.read(File.join(source_root, "button", "button.html.erb"))
    body = RubyUI::Herb::PhlexGenerator.generate_view_template(template)

    assert_includes body, "button("
    assert_includes body, "**attrs"
  end

  def test_visitor_generates_phlex_from_simple_template
    template = "<div <%= tag_attributes(attrs) %>><%= yield %></div>"
    body = RubyUI::Herb::PhlexGenerator.generate_view_template(template)

    assert_includes body, "div("
    assert_includes body, "**attrs"
    assert_match(/&/, body)
  end

  # ── Engine propagation to dependency generation ───────────────

  def test_engine_flag_propagated_to_dependencies
    engine = "erb"
    component = "Button"
    cmd = "bin/rails generate ruby_ui:component #{component} --force false --engine #{engine}"
    assert_includes cmd, "--engine erb"
  end

  private

  def source_root
    File.expand_path("../../lib/ruby_ui", __dir__)
  end
end
