require "test_helper"

class PrCommentTest < Minitest::Test
  HEAD = "a9a5d1faee2257e8e83c144a5be88c378347640d"
  MARKED = "<!-- shadcn-audit -->\nold"
  LIST = %w[gh api repos/ruby-ui/ruby_ui/issues/572/comments --paginate --jq] + [".[] | {id: .id, html_url: .html_url, body: .body}"]

  def shell(head: HEAD, comments: [])
    ShadcnAudit::FakeShell.new
      .stub(->(a) { a[0, 3] == %w[gh pr view] }, JSON.generate("headRefOid" => head))
      .stub(LIST, comments.map { |c| JSON.generate(c) }.join("\n"))
      .stub(->(a) { a[0] == "gh" && a.include?("-F") }, JSON.generate("html_url" => "https://github.com/x/y/pull/572#issuecomment-1"))
  end

  def writes(shell) = shell.argvs.select { |a| a.include?("-F") }

  def test_creates_when_no_marked_comment
    s = shell(comments: [{"id" => 5, "body" => "LGTM"}])
    result = ShadcnAudit::PrComment.new(shell: s).upsert(pr: 572, body: "<!-- shadcn-audit -->\nnew", expected_head_sha: HEAD)
    assert_equal "created", result["action"]
    assert_match(/issuecomment/, result["url"])
    assert_equal 1, writes(s).size
    assert_equal %w[gh api repos/ruby-ui/ruby_ui/issues/572/comments -F], writes(s).first[0, 4]
    refute_includes writes(s).first, "PATCH"
  end

  def test_updates_existing_marked_comment_even_if_edited
    s = shell(comments: [{"id" => 5, "body" => "LGTM"}, {"id" => 9, "body" => "edited by hand\n#{MARKED}"}])
    result = ShadcnAudit::PrComment.new(shell: s).upsert(pr: 572, body: "<!-- shadcn-audit -->\nnew", expected_head_sha: HEAD)
    assert_equal "updated", result["action"]
    write = writes(s).first
    assert_equal %w[gh api -X PATCH repos/ruby-ui/ruby_ui/issues/comments/9 -F], write[0, 6]
    assert_equal 1, writes(s).size
  end

  def test_body_is_sent_from_a_file_holding_the_body
    seen = nil
    s = ShadcnAudit::FakeShell.new
      .stub(->(a) { a[0, 3] == %w[gh pr view] }, JSON.generate("headRefOid" => HEAD))
      .stub(->(a) { a.include?("-F") && (seen = File.read(a.last.delete_prefix("body=@"))) && true }, "{}")
    ShadcnAudit::PrComment.new(shell: s).upsert(pr: 572, body: "hello body", expected_head_sha: HEAD)
    assert_equal "hello body", seen
  end

  def test_refuses_when_head_moved
    s = shell(head: "f" * 40)
    result = ShadcnAudit::PrComment.new(shell: s).upsert(pr: 572, body: "x", expected_head_sha: HEAD)
    assert_equal "refused", result["action"]
    assert_nil result["url"]
    assert_includes result["reason"], HEAD
    assert_includes result["reason"], "f" * 40
    assert_empty writes(s)
    refute s.argvs.any? { |a| a.include?("--paginate") }
  end
end
