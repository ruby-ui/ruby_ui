require "test_helper"

class TargetTest < Minitest::Test
  StubMap = Struct.new(:all_folders) do
    def component_folder_for_path(path)
      ShadcnAudit::ComponentMap::PATH_PATTERNS.each { |p| (m = p.match(path)) && (return m[1]) }
      nil
    end

    def entry(_folder) = nil

    def folder_for_name(name)
      snake = name.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
      snake if all_folders.include?(snake)
    end
  end

  ROOT = "/repo"

  def setup
    @shell = ShadcnAudit::FakeShell.new
    @map = StubMap.new(%w[alert_dialog dialog sheet])
  end

  def pr_json(paths)
    JSON.generate("headRefOid" => "head1", "baseRefOid" => "base1", "state" => "OPEN",
      "files" => paths.map { |p| {"path" => p, "additions" => 1} })
  end

  def stub_pr(paths)
    @shell.stub(->(a) { a[0, 3] == %w[gh pr view] && a.include?("headRefOid,baseRefOid,files,state") }, pr_json(paths))
  end

  def resolve(arg)
    ShadcnAudit::Target.resolve(arg, shell: @shell, map: @map, root: ROOT)
  end

  def test_pr_resolves_shas_and_components
    stub_pr(%w[gem/lib/ruby_ui/dialog/dialog_content.rb gem/test/ruby_ui/sheet_test.rb mcp/data/registry.json])
    result = resolve("572")
    assert_equal "pr", result["kind"]
    assert_equal "OPEN", result["state"]
    assert_equal 572, result["pr"]
    assert_equal "ruby-ui/ruby_ui", result["repo"]
    assert_equal "base1", result["base_sha"]
    assert_equal "head1", result["head_sha"]
    assert_equal %w[dialog sheet], result["components"]
    assert_equal [], result["unmapped"]
    assert_equal false, result["needs_selection"]
  end

  def test_pr_fetches_pull_ref_for_fork_heads
    stub_pr([])
    resolve("#572")
    assert @shell.called?("git", "fetch", "origin", "refs/pull/572/head")
    assert_equal ROOT, @shell.calls.find { |c| c.argv.first == "git" }.chdir
  end

  def test_unmapped_touched_component_is_kept_and_listed
    stub_pr(%w[gem/lib/ruby_ui/dialog/a.rb gem/lib/ruby_ui/new_thing/b.rb])
    result = resolve("572")
    assert_equal %w[dialog new_thing], result["components"]
    assert_equal %w[new_thing], result["unmapped"]
  end

  def test_shared_only_change_asks_for_selection
    stub_pr(%w[gem/lib/ruby_ui/base.rb])
    result = resolve("572")
    assert_equal [], result["components"]
    assert_equal true, result["needs_selection"]
    assert_equal @map.all_folders, result["candidates"]
  end

  def test_generators_path_is_shared
    stub_pr(%w[gem/lib/generators/ruby_ui/install_generator.rb])
    assert_equal true, resolve("572")["needs_selection"]
  end

  def test_shared_plus_component_does_not_ask_for_selection
    stub_pr(%w[gem/lib/ruby_ui/base.rb gem/lib/ruby_ui/sheet/sheet.rb])
    result = resolve("572")
    assert_equal false, result["needs_selection"]
    assert_equal [], result["candidates"]
  end

  def test_component_name_arg
    @shell.stub(%w[git rev-parse origin/main], "main1\n")
    %w[AlertDialog alert_dialog].each do |arg|
      result = resolve(arg)
      assert_equal "component", result["kind"]
      assert_equal %w[alert_dialog], result["components"]
      assert_equal "main1", result["head_sha"]
      assert_equal "main1", result["base_sha"]
    end
    assert @shell.called?("git", "fetch", "origin", "main")
  end

  def real_map
    ShadcnAudit::ComponentMap.new("dialog" => {"parts" => {"DialogContent" => {}}}, "sheet" => {})
  end

  def test_branch_wins_over_prefix_component_match
    @shell.stub(%w[git rev-parse --verify --quiet dialog_fix^{commit}], "headx\n")
    @shell.stub(%w[git merge-base origin/main dialog_fix], "basex\n")
    @shell.stub(%w[git diff --name-only basex...headx], "gem/lib/ruby_ui/sheet/sheet.rb\n")
    result = ShadcnAudit::Target.resolve("dialog_fix", shell: @shell, map: real_map, root: ROOT)
    assert_equal "branch", result["kind"]
    assert_equal %w[sheet], result["components"]
  end

  def test_part_name_without_branch_is_component
    result = ShadcnAudit::Target.resolve("DialogContent", shell: @shell, map: real_map, root: ROOT)
    assert_equal "component", result["kind"]
    assert_equal %w[dialog], result["components"]
  end

  def test_unknown_arg_raises
    assert_raises(ArgumentError) do
      ShadcnAudit::Target.resolve("dialog_fix", shell: @shell, map: real_map, root: ROOT)
    end
  end

  def test_branch_arg
    @shell.stub(%w[git rev-parse --verify --quiet feature/x^{commit}], "head2\n")
    @shell.stub(%w[git merge-base origin/main feature/x], "base2\n")
    @shell.stub(%w[git diff --name-only base2...head2], "gem/lib/ruby_ui/sheet/sheet.rb\n")
    result = resolve("feature/x")
    assert_equal "branch", result["kind"]
    assert @shell.called?("git", "fetch", "origin", "main")
    assert_nil result["state"]
    assert_nil result["pr"]
    assert_equal "base2", result["base_sha"]
    assert_equal "head2", result["head_sha"]
    assert_equal %w[sheet], result["components"]
  end

  def test_docs_view_and_controller_paths_map_to_folder
    stub_pr(%w[docs/app/views/docs/alert_dialog.rb])
    assert_equal %w[alert_dialog], resolve("572")["components"]
  end

  def test_head_sha_for_pr
    @shell.stub(%w[gh pr view 572 --repo ruby-ui/ruby_ui --json headRefOid], '{"headRefOid":"abc"}')
    assert_equal "abc", ShadcnAudit::Target.head_sha_for_pr(572, shell: @shell)
  end
end
