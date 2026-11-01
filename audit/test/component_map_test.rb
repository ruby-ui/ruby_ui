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

    assert_equal "alert-dialog", parsed["shadcn"]
    assert_equal "alert_dialog", parsed["docs_view"]
    assert_equal "audit/component_map/alert_dialog.yml", ShadcnAudit::ComponentMap.path_for("alert_dialog")
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

  def test_fixture_shadcn_must_be_a_list_of_names
    File.write(@path, "form:\n  shadcn: field\n  kind: form_control\n  fixture_shadcn: input\n")
    error = assert_raises(ShadcnAudit::ConfigError) { ShadcnAudit::ComponentMap.load(@path) }
    assert_includes error.message, "form"
    assert_includes error.message, "fixture_shadcn"
  end

  def test_fixture_shadcn_rejects_malformed_names
    ["", "Input", "input group", "../input"].each do |name|
      File.write(@path, "form:\n  shadcn: field\n  kind: form_control\n  fixture_shadcn: [#{name.inspect}]\n")
      error = assert_raises(ShadcnAudit::ConfigError, name) { ShadcnAudit::ComponentMap.load(@path) }
      assert_includes error.message, "fixture_shadcn"
    end
  end

  def test_form_fixture_declares_its_extra_components
    assert_equal %w[button input checkbox], seed_map.entry("form")["fixture_shadcn"]
  end

  def seed_map = ShadcnAudit::ComponentMap.for_audit(ShadcnAudit.root.join("audit"))

  def test_seed_files_load
    map = seed_map
    assert_includes map.all_folders, "dialog"

    map.all_folders.each do |folder|
      shadcn = map.entry(folder)["shadcn"]
      next if shadcn.nil?

      assert_match(/\A[a-z]+(-[a-z]+)*\z/, shadcn, folder)
    end
  end

  def test_seed_shadcn_names_exist_in_the_workspace_clone
    ui_dir = ShadcnAudit.workspace_dir.join("ui")
    skip "no shadcn workspace at #{ui_dir}; run `exe/shadcn-audit workspace` to check the names" unless ui_dir.exist?

    seed_map.all_folders.filter_map { |folder| [folder, seed_map.entry(folder)["shadcn"]] if seed_map.entry(folder)["shadcn"] }.each do |folder, shadcn|
      assert ui_dir.join("apps/v4/registry/bases/base/ui/#{shadcn}.tsx").exist?, "#{folder}: missing #{shadcn}.tsx"
    end
  end

  def test_split_directory_loads_one_file_per_folder
    dir = File.join(@tmp, "audit", "component_map")
    FileUtils.mkdir_p(dir)
    File.write(File.join(dir, "sheet.yml"), "shadcn: sheet\nkind: modal\n")
    File.write(File.join(dir, "dialog.yml"), "shadcn: dialog\nkind: modal\n")
    File.write(File.join(dir, "README.md"), "not an entry")

    map = ShadcnAudit::ComponentMap.for_audit(File.join(@tmp, "audit"))

    assert_equal %w[dialog sheet], map.all_folders
    assert_equal "sheet", map.entry("sheet")["shadcn"]
  end

  def test_split_directory_errors_name_the_file
    dir = File.join(@tmp, "component_map")
    FileUtils.mkdir_p(dir)
    File.write(File.join(dir, "dialog.yml"), "shadcn: dialog\nkind: wizard\n")

    error = assert_raises(ShadcnAudit::ConfigError) { ShadcnAudit::ComponentMap.load(dir) }
    assert_match(/\Acomponent_map\/dialog\.yml: unknown kind/, error.message)
  end

  def test_audit_dir_without_split_falls_back_to_the_single_file
    # Preview checkouts of SHAs from before the split still have audit/component_map.yml.
    audit = File.join(@tmp, "old_audit")
    FileUtils.mkdir_p(audit)
    File.write(File.join(audit, "component_map.yml"), "dialog:\n  shadcn: dialog\n  kind: modal\n")

    assert_equal %w[dialog], ShadcnAudit::ComponentMap.for_audit(audit).all_folders
  end

  def test_every_fixture_has_a_map_file_and_every_compared_entry_has_fixtures
    audit = ShadcnAudit.root.join("audit")
    compared = seed_map.all_folders.reject { |folder| seed_map.selectors(folder).compact.empty? }
    assert_equal compared.sort, Dir.children(audit.join("fixtures")).sort
    Dir.children(audit.join("fixtures")).each do |folder|
      assert File.file?(audit.join("component_map", "#{folder}.yml")), "#{folder}: missing map file"
    end
  end

  def test_non_mapping_entry_raises
    File.write(@path, "dialog: dialog\n")
    error = assert_raises(ShadcnAudit::ConfigError) { ShadcnAudit::ComponentMap.load(@path) }
    assert_equal "component_map.yml: dialog: entry must be a mapping", error.message
  end

  def selector_map(selectors)
    ShadcnAudit::ComponentMap.new("dialog" => {"parts" => {"DialogContent" => "dialog-content"}, "selectors" => selectors})
  end

  def test_selectors_are_returned
    assert_equal({"DialogContent" => "dialog > div"}, selector_map("DialogContent" => "dialog > div").selectors("dialog"))
  end

  def test_selectors_default_to_empty
    assert_equal({}, @map.selectors("dialog"))
  end

  def test_selector_for_unknown_part_is_rejected
    error = assert_raises(ShadcnAudit::ConfigError) { selector_map("Nope" => "div") }
    assert_match(/selectors.Nope is not a mapped part/, error.message)
  end

  def test_null_selector_means_not_compared
    assert_equal({"DialogContent" => nil}, selector_map("DialogContent" => nil).selectors("dialog"))
  end

  def test_blank_selector_is_rejected
    error = assert_raises(ShadcnAudit::ConfigError) { selector_map("DialogContent" => " ") }
    assert_match(/selectors.DialogContent must be a non-empty CSS selector/, error.message)
  end

  def test_selectors_must_be_a_mapping
    error = assert_raises(ShadcnAudit::ConfigError) { selector_map(["dialog > div"]) }
    assert_match(/selectors must be a mapping/, error.message)
  end

  def test_selector_on_part_without_shadcn_slot_is_rejected
    map = {"dialog" => {"parts" => {"DialogMiddle" => nil}, "selectors" => {"DialogMiddle" => "div"}}}
    error = assert_raises(ShadcnAudit::ConfigError) { ShadcnAudit::ComponentMap.new(map) }
    assert_match(/selectors.DialogMiddle is not a mapped part/, error.message)
  end
end
