require "test_helper"

class CollectGraderTest < Minitest::Test
  Grader = ShadcnAudit::Collect::Grader

  def side(parts)
    {"reached" => true, "reason" => nil, "screenshot" => "screens/x.png", "parts" => parts}
  end

  def unreached(reason)
    {"reached" => false, "reason" => reason, "screenshot" => nil, "parts" => {}}
  end

  def el(styles = {}, aria = "- dialog", attrs = {})
    {"styles" => styles, "aria" => aria, "attrs" => attrs}
  end

  def obs(state, theme, rubyui, shadcn)
    {"state" => state, "theme" => theme, "rubyui" => rubyui, "shadcn" => shadcn}
  end

  def grader(parts: %w[DialogContent DialogTitle], divergences: [], theme_diffs: [], env: [])
    Grader.new(folder: "dialog", parts: parts, divergences: ShadcnAudit::Divergences.new(divergences),
      theme_diffs: theme_diffs, environment_diff_keys: env)
  end

  def look(lines) = lines.select { |l| l["dimension"] == "Look" }

  def same_parts(styles = {"padding-top" => "24px"})
    side("DialogContent" => [el(styles)], "DialogTitle" => [el(styles)])
  end

  def test_matching_parts_group_into_one_pass_line
    lines = look(grader.lines([obs("open", "light", same_parts, same_parts)]))
    assert_equal 1, lines.size
    assert_equal "pass", lines[0]["status"]
    assert_equal "DialogContent, DialogTitle: computed styles match", lines[0]["rubyui"]
    assert_equal Grader::LOOK_SOURCE, lines[0]["source"]
  end

  def test_style_difference_is_fail_with_both_values
    r = side("DialogContent" => [el("padding-top" => "24px")])
    s = side("DialogContent" => [el("padding-top" => "16px")])
    lines = look(grader(parts: %w[DialogContent]).lines([obs("open", "light", r, s), obs("open", "dark", r, s)]))
    fail_line = lines.find { |l| l["status"] == "fail" }
    assert_equal "padding-top: 24px", fail_line["rubyui"]
    assert_equal "padding-top: 16px", fail_line["shadcn"]
    assert_equal "DialogContent — open/light, open/dark", fail_line["note"]
    assert_equal Grader::LOOK_SOURCE, fail_line["source"]
    assert_nil fail_line["basis"]
  end

  def test_count_mismatch_is_inconclusive
    r = side("Item" => [el, el])
    s = side("Item" => [el, el, el])
    lines = look(grader(parts: %w[Item]).lines([obs("open", "light", r, s)]))
    assert_equal ["inconclusive"], lines.map { |l| l["status"] }
    assert_equal "Item: selector matched 2/3 visible elements in open/light", lines[0]["note"]
  end

  def test_theme_token_explains_difference
    diff = {"mode" => "light", "token" => "chart-1", "rubyui" => "oklch(0.646 0.222 41.116)", "shadcn" => "oklch(0.809 0.105 251.813)"}
    r = side("DialogContent" => [el("color" => "oklch(0.646 0.222 41.116)")])
    s = side("DialogContent" => [el("color" => "oklch(0.809 0.105 251.813)")])
    lines = look(grader(parts: %w[DialogContent], theme_diffs: [diff]).lines([obs("open", "light", r, s)]))
    assert_equal ["inconclusive"], lines.map { |l| l["status"] }
    assert_includes lines[0]["note"], "chart-1"
  end

  def test_font_environment_explains_typography_only
    r = side("DialogContent" => [el("font-size" => "14px", "padding-top" => "24px")])
    s = side("DialogContent" => [el("font-size" => "16px", "padding-top" => "16px")])
    lines = look(grader(parts: %w[DialogContent], env: ["font"]).lines([obs("open", "light", r, s)]))
    assert_equal %w[fail inconclusive], lines.map { |l| l["status"] }
    assert_equal "padding-top: 24px", lines[0]["rubyui"]
    assert_includes lines[1]["note"], "environment diff: font"
  end

  def test_structured_divergence_passes_as_intentional
    entry = {"component" => "dialog", "dimension" => "Look", "rubyui" => "border", "shadcn" => "ring", "reason" => "Kept the border.",
             "match" => {"part" => "DialogContent", "property" => "border-top-width", "rubyui" => "1px", "shadcn" => "0px"}}
    r = side("DialogContent" => [el("border-top-width" => "1px")])
    s = side("DialogContent" => [el("border-top-width" => "0px")])
    lines = look(grader(parts: %w[DialogContent], divergences: [entry]).lines([obs("open", "light", r, s)]))
    assert_equal 1, lines.size
    assert_equal({"status" => "pass", "basis" => "intentional", "source" => "audit/divergences/dialog.yml"},
      lines[0].slice("status", "basis", "source"))
    assert_includes lines[0]["note"], "Kept the border."
  end

  def test_output_is_order_independent
    a = side("DialogContent" => [el("padding-top" => "24px", "gap" => "4px")], "DialogTitle" => [el("color" => "red")])
    b = side("DialogTitle" => [el("color" => "blue")], "DialogContent" => [el("gap" => "6px", "padding-top" => "16px")])
    observations = [obs("open", "light", a, b), obs("closed", "dark", a, b), obs("open", "dark", a, b)]
    assert_equal grader.lines(observations), grader.lines(observations.reverse)
  end

  def test_unreached_observations_are_skipped_for_comparison
    r = unreached("no [data-audit-trigger]")
    s = side("DialogContent" => [el("padding-top" => "16px")])
    lines = look(grader(parts: %w[DialogContent]).lines([obs("open", "light", r, s)]))
    refute(lines.any? { |l| l["status"] == "fail" })
  end

  def aria(lines) = lines.select { |l| l["dimension"] == "ARIA" }

  def test_aria_snapshot_difference_is_warn
    r = side("Trigger" => [el({}, %(- button "Open" [expanded]))])
    s = side("Trigger" => [el({}, %(- button "Open"))])
    lines = aria(grader(parts: %w[Trigger]).lines([obs("open", "light", r, s)]))
    assert_equal ["warn"], lines.map { |l| l["status"] }
    assert_equal %(snapshot: only here: - button "Open" [expanded]), lines[0]["rubyui"]
    assert_equal Grader::ARIA_SOURCE, lines[0]["source"]
  end

  def test_missing_attribute_is_warn
    r = side("Trigger" => [el({}, "- button", {"aria-controls" => "resolves"})])
    s = side("Trigger" => [el({}, "- button", {"aria-controls" => nil})])
    lines = aria(grader(parts: %w[Trigger]).lines([obs("open", "light", r, s)]))
    assert_equal ["warn"], lines.map { |l| l["status"] }
    assert_equal "aria-controls: (none)", lines[0]["shadcn"]
    assert_equal "aria-controls: resolves", lines[0]["rubyui"]
  end

  def test_matching_aria_groups_into_pass
    lines = aria(grader.lines([obs("open", "light", same_parts, same_parts)]))
    assert_equal [["pass", "DialogContent, DialogTitle: accessibility tree matches"]], lines.map { |l| [l["status"], l["rubyui"]] }
  end

  def test_aria_divergence_by_attribute_is_intentional
    entry = {"component" => "dialog", "dimension" => "ARIA", "rubyui" => "x", "shadcn" => "y", "reason" => "Native details.",
             "match" => {"part" => "Trigger", "attribute" => "aria-expanded", "rubyui" => "", "shadcn" => "true"}}
    r = side("Trigger" => [el({}, "- button", {"aria-expanded" => nil})])
    s = side("Trigger" => [el({}, "- button", {"aria-expanded" => "true"})])
    lines = aria(grader(parts: %w[Trigger], divergences: [entry]).lines([obs("open", "light", r, s)]))
    assert_equal [["pass", "intentional"]], lines.map { |l| [l["status"], l["basis"]] }
  end

  def test_unreached_state_yields_inconclusive_look_and_aria
    s = side("DialogContent" => [el])
    observations = [obs("open", "light", unreached("no [data-audit-trigger]"), s), obs("open", "dark", unreached("no [data-audit-trigger]"), s)]
    lines = grader(parts: %w[DialogContent]).lines(observations)
    assert_equal [%w[Look inconclusive], %w[ARIA inconclusive]], lines.map { |l| [l["dimension"], l["status"]] }
    assert_equal "open/light, open/dark not reached on rubyui: no [data-audit-trigger]", lines[0]["note"]
  end

  def test_snapshot_difference_shows_only_differing_lines
    common = %(- dialog "Edit":\n  - heading "Edit" [level=2]\n  - button "Close")
    r = side("DialogContent" => [el({}, "#{common}:\n    - img\n    - text: Close")])
    s = side("DialogContent" => [el({}, common)])
    line = aria(grader(parts: %w[DialogContent]).lines([obs("open", "light", r, s)])).first
    assert_equal %(snapshot: only here:   - button "Close": |     - img |     - text: Close), line["rubyui"]
    assert_equal %(snapshot: only here:   - button "Close"), line["shadcn"]
  end

  def test_theme_explained_note_names_the_part
    diff = {"mode" => "light", "token" => "chart-1", "rubyui" => "red", "shadcn" => "blue"}
    r = side("DialogContent" => [el("color" => "red")])
    s = side("DialogContent" => [el("color" => "blue")])
    line = look(grader(parts: %w[DialogContent], theme_diffs: [diff]).lines([obs("open", "light", r, s)])).first
    assert_equal "DialogContent — explained by theme token chart-1", line["note"]
  end

  def test_environment_explained_parts_share_one_line
    r = side("DialogContent" => [el("font-size" => "14px")], "DialogTitle" => [el("width" => "10px")])
    s = side("DialogContent" => [el("font-size" => "16px")], "DialogTitle" => [el("width" => "12px")])
    lines = look(grader(env: ["font"]).lines([obs("open", "light", r, s)]))
    assert_equal 1, lines.size
    assert_equal ["inconclusive", "properties: font-size, width", "DialogContent, DialogTitle — explained by environment diff: font"],
      lines[0].values_at("status", "rubyui", "note")
  end

  def test_part_never_visible_is_inconclusive_not_pass
    empty = side("DialogContent" => [], "DialogTitle" => [el])
    lines = grader.lines([obs("closed", "light", empty, empty)])
    notes = lines.map { |l| [l["dimension"], l["status"], l["note"]] }
    assert_includes notes, ["Look", "inconclusive", "DialogContent: no visible element in any reached state"]
    assert_includes notes, ["ARIA", "inconclusive", "DialogContent: no visible element in any reached state"]
    refute(lines.any? { |l| l["status"] == "pass" && l["rubyui"].include?("DialogContent") })
  end

  def test_aria_snapshot_keeps_hierarchy
    r = side("List" => [el({}, %(- list:\n  - button "Two"))])
    s = side("List" => [el({}, %(- list:\n- button "Two"))])
    assert_equal ["warn"], aria(grader(parts: %w[List]).lines([obs("open", "light", r, s)])).map { |l| l["status"] }
  end

  def test_aria_snapshot_keeps_case_and_numbers
    r = side("Item" => [el({}, %(- button "Page 1.50"))])
    s = side("Item" => [el({}, %(- button "page 1.5"))])
    assert_equal ["warn"], aria(grader(parts: %w[Item]).lines([obs("open", "light", r, s)])).map { |l| l["status"] }
  end

  def test_modal_fact_difference_is_warn
    r = side("Content" => [el({}, "- dialog", {"modal" => "true"})])
    s = side("Content" => [el({}, "- dialog", {"modal" => nil})])
    line = aria(grader(parts: %w[Content]).lines([obs("open", "light", r, s)])).first
    assert_equal ["warn", "modal: true", "modal: (none)"], line.values_at("status", "rubyui", "shadcn")
  end

  def test_snapshot_delta_keeps_repeated_nodes
    r = side("List" => [el({}, "- listitem: A\n- listitem: A\n- listitem: A")])
    s = side("List" => [el({}, "- listitem: A\n- listitem: A")])
    line = aria(grader(parts: %w[List]).lines([obs("open", "light", r, s)])).first
    assert_equal "snapshot: only here: - listitem: A", line["rubyui"]
  end

  def test_snapshot_delta_shows_nesting
    r = side("List" => [el({}, %(- list:\n  - button "Two"))])
    s = side("List" => [el({}, %(- list:\n- button "Two"))])
    line = aria(grader(parts: %w[List]).lines([obs("open", "light", r, s)])).first
    assert_equal %(snapshot: only here:   - button "Two"), line["rubyui"]
    assert_equal %(snapshot: only here: - button "Two"), line["shadcn"]
  end
end
