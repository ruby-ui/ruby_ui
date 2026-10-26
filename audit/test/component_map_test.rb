require "test_helper"

class ComponentMapTest < Minitest::Test
  def setup
    @tmp = Dir.mktmpdir
    @path = File.join(@tmp, "map.yml")
    File.write(@path, <<~YAML)
      dialog:
        shadcn: dialog
        kind: modal
        docs_view: dialog
        parts: {Dialog: dialog, DialogContent: dialog-content}
        props: {DialogContent: {showCloseButton: null}}
        rubyui_only: {DialogContent: [size]}
      sheet:
        shadcn: sheet
        kind: modal
        docs_view: sheet
        parts: {Sheet: sheet, SheetContent: sheet-content}
        props: {}
      command:
        shadcn: command
        kind: popover
        docs_view: command
        parts: {Command: command, CommandDialog: dialog}
        props: {}
    YAML
    @map = ShadcnAudit::ComponentMap.load(@path)
  end

  def teardown
    FileUtils.remove_entry(@tmp)
  end

  def test_entry_and_all_folders
    assert_equal "dialog", @map.entry("dialog")["shadcn"]
    assert_nil @map.entry("nope")
    assert_equal %w[dialog sheet command], @map.all_folders
  end

  def test_folder_for_path_maps_known_folders
    assert_equal "sheet", @map.folder_for_path("gem/lib/ruby_ui/sheet/sheet_content.rb")
    assert_equal "sheet", @map.folder_for_path("gem/lib/ruby_ui/sheet/sheet_content_controller.js")
    assert_equal "dialog", @map.folder_for_path("gem/test/ruby_ui/dialog_test.rb")
    assert_equal "command", @map.folder_for_path("docs/app/views/docs/command.rb")
  end

  def test_folder_for_path_is_nil_for_unmapped_or_unrelated
    assert_nil @map.folder_for_path("gem/lib/ruby_ui/button/button.rb")
    assert_nil @map.folder_for_path("docs/app/views/pages/home.rb")
    assert_nil @map.folder_for_path("README.md")
  end

  def test_component_folder_for_path_ignores_mapping
    assert_equal "button", @map.component_folder_for_path("gem/lib/ruby_ui/button/button.rb")
    assert_equal "button", @map.component_folder_for_path("gem/test/ruby_ui/button_test.rb")
    assert_equal "button", @map.component_folder_for_path("docs/app/views/docs/button.rb")
    assert_nil @map.component_folder_for_path("docs/app/views/pages/home.rb")
  end

  def test_folder_for_name
    assert_equal "command", @map.folder_for_name("CommandDialog")
    assert_equal "sheet", @map.folder_for_name("SheetContent")
    assert_equal "dialog", @map.folder_for_name("dialog")
    assert_equal "dialog", @map.folder_for_name("DialogFooter")
    assert_nil @map.folder_for_name("Button")
  end

  def test_unmapped_folder_returns_nil_and_suggests_entry
    assert_nil @map.entry("alert_dialog")
    stub = @map.suggest_entry("alert_dialog")
    parsed = YAML.safe_load(stub)

    assert_equal "alert-dialog", parsed["alert_dialog"]["shadcn"]
    assert_equal "alert_dialog", parsed["alert_dialog"]["docs_view"]
  end

  def test_unknown_kind_raises
    File.write(@path, "dialog:\n  shadcn: dialog\n  kind: wizard\n")
    error = assert_raises(ShadcnAudit::ConfigError) { ShadcnAudit::ComponentMap.load(@path) }
    assert_includes error.message, "dialog"
    assert_includes error.message, "wizard"
  end

  def test_rubyui_only_is_exposed_on_entry
    assert_equal({"DialogContent" => ["size"]}, @map.entry("dialog")["rubyui_only"])
    assert_equal({"DialogContent" => {"showCloseButton" => nil}}, @map.entry("dialog")["props"])
  end

  def test_rubyui_only_must_hold_arrays
    File.write(@path, "dialog:\n  shadcn: dialog\n  kind: modal\n  rubyui_only: {DialogContent: size}\n")
    error = assert_raises(ShadcnAudit::ConfigError) { ShadcnAudit::ComponentMap.load(@path) }
    assert_includes error.message, "dialog"
    assert_includes error.message, "rubyui_only.DialogContent"
  end

  def test_seed_files_load
    map = ShadcnAudit::ComponentMap.load(ShadcnAudit.root.join("audit/component_map.yml"))
    assert_includes map.all_folders, "dialog"
    ui_dir = ShadcnAudit.workspace_dir.join("ui")

    map.all_folders.each do |folder|
      shadcn = map.entry(folder)["shadcn"]
      next if shadcn.nil?

      assert_match(/\A[a-z]+(-[a-z]+)*\z/, shadcn, folder)
      next unless ui_dir.exist?

      assert ui_dir.join("apps/v4/registry/bases/base/ui/#{shadcn}.tsx").exist?, "#{folder}: missing #{shadcn}.tsx"
    end
  end
end
