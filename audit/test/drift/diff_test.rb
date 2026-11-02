require "test_helper"

class DriftDiffTest < Minitest::Test
  Diff = ShadcnAudit::Drift::Diff

  def ref(parts: {}, variants: {}, warnings: [])
    {"parts" => parts.transform_values { |classes| {"effective" => classes} }, "variants" => variants, "warnings" => warnings}
  end

  def test_reports_added_and_removed_classes_per_slot
    diff = Diff.compare(ref(parts: {"checkbox" => %w[size-4 rounded-sm]}), ref(parts: {"checkbox" => %w[size-4 rounded-md]}))

    assert_equal({"checkbox" => {"added" => ["rounded-md"], "removed" => ["rounded-sm"]}}, diff["classes"])
    refute Diff.empty?(diff)
  end

  def test_reports_added_and_removed_parts
    diff = Diff.compare(ref(parts: {"a" => [], "b" => []}), ref(parts: {"b" => [], "c" => []}))

    assert_equal ["c"], diff["parts_added"]
    assert_equal ["a"], diff["parts_removed"]
    assert_empty diff["classes"]
  end

  def test_reports_variant_changes_by_path
    before = ref(variants: {"buttonVariants" => {"size" => {"sm" => %w[h-8], "lg" => %w[h-10]}}})
    after = ref(variants: {"buttonVariants" => {"size" => {"sm" => %w[h-7], "lg" => %w[h-10]}}})

    assert_equal({"buttonVariants/size/sm" => {"added" => ["h-7"], "removed" => ["h-8"]}}, Diff.compare(before, after)["variants"])
  end

  def test_new_variant_counts_as_added_classes
    after = ref(variants: {"buttonVariants" => {"size" => {"xs" => %w[h-6]}}})

    assert_equal({"buttonVariants/size/xs" => {"added" => ["h-6"], "removed" => []}}, Diff.compare(ref, after)["variants"])
  end

  def test_class_order_change_is_not_a_change
    assert Diff.empty?(Diff.compare(ref(parts: {"x" => %w[a b]}), ref(parts: {"x" => %w[b a]})))
  end

  def test_new_warning_alone_is_not_empty
    diff = Diff.compare(ref(parts: {"x" => %w[a]}), ref(parts: {"x" => %w[a]}, warnings: ["x"]))

    assert_equal ["x"], diff["warnings_added"]
    refute Diff.empty?(diff)
  end
end
