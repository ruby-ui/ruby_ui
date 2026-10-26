require "json"
require "tempfile"
require "shadcn_audit/renderers/markdown"

module ShadcnAudit
  # Keeps one marked audit comment per PR, authored by the authenticated gh
  # user. Refuses when the PR isn't open or its head moved since the audit
  # pinned it. The only code path that writes to GitHub.
  class PrComment
    API = "repos/#{Target::REPO}".freeze

    def initialize(shell:)
      @shell = shell
    end

    def upsert(pr:, body:, expected_head_sha:)
      head = Target.pr_head(pr, shell: @shell)
      if head["state"] != "OPEN"
        return refused("PR ##{pr} is #{head["state"] || "in an unknown state"}, not OPEN. Nothing was posted.")
      end
      current = head["head_sha"]
      if current != expected_head_sha
        return refused("PR ##{pr} head moved: audited #{expected_head_sha}, now #{current}. Re-run the audit.")
      end

      existing = marked_comment(pr, login)
      with_body_file(body) do |file|
        if existing
          result = JSON.parse(@shell.capture("gh", "api", "-X", "PATCH", "#{API}/issues/comments/#{existing["id"]}", "-F", "body=@#{file}"))
          {"action" => "updated", "url" => result["html_url"] || existing["html_url"], "reason" => nil}
        else
          result = JSON.parse(@shell.capture("gh", "api", "#{API}/issues/#{pr}/comments", "-F", "body=@#{file}"))
          {"action" => "created", "url" => result["html_url"], "reason" => nil}
        end
      end
    end

    private

    def refused(reason) = {"action" => "refused", "url" => nil, "reason" => reason}

    def login = @shell.capture("gh", "api", "user", "--jq", ".login").strip

    # Only the authenticated user's own marked comment is updated: a
    # maintainer token can edit anyone's comment, so a marker pasted by
    # someone else must never be overwritten. --jq flattens pages into one
    # compact JSON object per line, so concatenated page arrays never need
    # splitting.
    def marked_comment(pr, login)
      out = @shell.capture("gh", "api", "#{API}/issues/#{pr}/comments", "--paginate",
        "--jq", ".[] | {id: .id, html_url: .html_url, body: .body, user: .user.login}")
      out.lines.map(&:strip).reject(&:empty?).flat_map { |l| [JSON.parse(l)].flatten }
        .find { |c| c["user"] == login && c["body"].to_s.include?(Renderers::Markdown::MARKER) }
    end

    def with_body_file(body)
      Tempfile.create(["shadcn-audit", ".md"]) do |f|
        f.write(body)
        f.flush
        yield f.path
      end
    end
  end
end
