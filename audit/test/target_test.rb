require "test_helper"

class TargetTest < Minitest::Test
  ROOT = "/repo"

  def setup
    @shell = ShadcnAudit::FakeShell.new
    @map = ShadcnAudit::ComponentMap.new(
      "alert_dialog" => {"shadcn" => "alert-dialog", "kind" => "modal"},
      "dialog" => {"shadcn" => "dialog", "kind" => "modal", "parts" => {"DialogContent" => "dialog-content"}},
      "sheet" => {"shadcn" => "sheet", "kind" => "modal"}
    )
  end

  URL = "https://github.com/ruby-ui/ruby_ui.git"
  MAIN_FETCH = ["git", "fetch", URL, "+refs/heads/main:refs/shadcn-audit/main"]

  def pr_json(paths, cross: false, owner: "ruby-ui")
    JSON.generate("headRefOid" => "head1", "baseRefOid" => "base1", "state" => "OPEN",
      "isCrossRepository" => cross, "headRepositoryOwner" => {"login" => owner},
      "files" => paths.map { |p| {"path" => p, "additions" => 1} })
  end

  def stub_pr(paths, **opts)
    @shell.stub(->(a) { a[0, 3] == %w[gh pr view] && a.include?("headRefOid,baseRefOid,files,state,isCrossRepository,headRepositoryOwner") }, pr_json(paths, **opts))
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
    assert_equal false, result["cross_repository"]
  end

  def test_pr_fetches_pull_ref_and_main_from_upstream_not_origin
    stub_pr([])
    resolve("#572")
    assert @shell.called?("git", "fetch", URL, "refs/pull/572/head", "+refs/heads/main:refs/shadcn-audit/main")
    assert_equal ROOT, @shell.calls.find { |c| c.argv.first == "git" }.chdir
    refute @shell.argvs.flatten.include?("origin")
  end

  def test_fork_pr_is_cross_repository
    stub_pr([], cross: true, owner: "someone")
    assert_equal true, resolve("572")["cross_repository"]
  end

  def test_pr_from_another_owner_is_cross_repository_even_without_the_flag
    stub_pr([], cross: false, owner: "someone")
    assert_equal true, resolve("572")["cross_repository"]
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
    @shell.stub(%w[git rev-parse refs/shadcn-audit/main], "main1\n")
    %w[AlertDialog alert_dialog].each do |arg|
      result = resolve(arg)
      assert_equal "component", result["kind"]
      assert_equal %w[alert_dialog], result["components"]
      assert_equal "main1", result["head_sha"]
      assert_equal "main1", result["base_sha"]
      assert_equal false, result["cross_repository"]
    end
    assert @shell.called?(*MAIN_FETCH)
  end

  def test_branch_wins_over_prefix_component_match
    @shell.stub(%w[git rev-parse --verify --quiet dialog_fix^{commit}], "headx\n")
    @shell.stub(%w[git merge-base refs/shadcn-audit/main dialog_fix], "basex\n")
    @shell.stub(%w[git diff --name-only basex...headx], "gem/lib/ruby_ui/sheet/sheet.rb\n")
    result = ShadcnAudit::Target.resolve("dialog_fix", shell: @shell, map: @map, root: ROOT)
    assert_equal "branch", result["kind"]
    assert_equal %w[sheet], result["components"]
  end

  def test_part_name_without_branch_is_component
    result = ShadcnAudit::Target.resolve("DialogContent", shell: @shell, map: @map, root: ROOT)
    assert_equal "component", result["kind"]
    assert_equal %w[dialog], result["components"]
  end

  def test_unknown_arg_raises
    assert_raises(ArgumentError) do
      ShadcnAudit::Target.resolve("dialog_fix", shell: @shell, map: @map, root: ROOT)
    end
  end

  def test_branch_arg
    @shell.stub(%w[git rev-parse --verify --quiet feature/x^{commit}], "head2\n")
    @shell.stub(%w[git merge-base refs/shadcn-audit/main feature/x], "base2\n")
    @shell.stub(%w[git diff --name-only base2...head2], "gem/lib/ruby_ui/sheet/sheet.rb\n")
    result = resolve("feature/x")
    assert_equal "branch", result["kind"]
    assert @shell.called?(*MAIN_FETCH)
    refute @shell.argvs.flatten.include?("origin/main")
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

  def test_pr_head
    @shell.stub(%w[gh pr view 572 --repo ruby-ui/ruby_ui --json headRefOid,state], '{"headRefOid":"abc","state":"MERGED"}')
    assert_equal({"head_sha" => "abc", "state" => "MERGED"}, ShadcnAudit::Target.pr_head(572, shell: @shell))
  end
end
