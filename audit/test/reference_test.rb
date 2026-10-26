require "test_helper"

class ReferenceTest < Minitest::Test
  FIXTURES = File.expand_path("fixtures/registry", __dir__)

  def setup
    @reference = ShadcnAudit::Reference.new(registry_dir: FIXTURES)
    @dialog = @reference.for("dialog")
  end

  def test_dialog_content_effective_classes
    effective = @dialog["parts"]["dialog-content"]["effective"]
    %w[fixed top-1/2 rounded-xl p-6 gap-6 ring-1 ring-foreground/10 sm:max-w-md].each do |klass|
      assert_includes effective, klass
    end
    refute_includes effective, "cn-dialog-content"
  end

  def test_dialog_content_props
    assert_equal ["showCloseButton"], @dialog["parts"]["dialog-content"]["props"]
  end

  def test_dialog_overlay_effective_classes
    effective = @dialog["parts"]["dialog-overlay"]["effective"]
    assert_includes effective, "bg-black/10"
    assert_includes effective, "supports-backdrop-filter:backdrop-blur-xs"
  end

  def test_dialog_parts_and_clean_resolution
    %w[dialog-overlay dialog-content dialog-header dialog-footer dialog-title dialog-description].each do |slot|
      assert @dialog["parts"].key?(slot), slot
    end
    assert_equal [], @dialog["unresolved"]
    assert_equal false, @dialog["missing"]
  end

  def test_effective_keeps_order_and_drops_duplicates
    part = @dialog["parts"]["dialog-footer"]
    assert_equal %w[cn-dialog-footer], part["cn"]
    assert_equal part["effective"].uniq, part["effective"]
    assert_equal "flex", part["effective"].first
  end

  def test_cn_font_heading_without_a_rule_is_aliased_and_warned
    assert_includes @dialog["parts"]["dialog-title"]["effective"], "font-heading"
    assert(@dialog["warnings"].any? { |w| w.start_with?("cn-font-heading") })
  end

  def test_slot_used_twice_keeps_both_without_dropping_classes
    close = @dialog["parts"]["dialog-close"]
    assert_equal "DialogClose", close["function"]
    also = close["also"].first
    assert_equal "DialogContent", also["function"]
    assert_equal %w[absolute top-4 right-4], also["effective"]
    assert(@dialog["warnings"].any? { |w| w.include?("rendered through <Button>") })
  end

  def test_button_cva_variants
    variants = @reference.for("button")["variants"]["buttonVariants"]
    refute_empty variants["variant"]["default"]
    assert variants["size"].key?("default")
  end

  def test_button_part_includes_cva_base_classes
    effective = @reference.for("button")["parts"]["button"]["effective"]
    assert_includes effective, "inline-flex"
    assert_includes effective, "rounded-md"
  end

  def test_missing_component
    result = @reference.for("no-such")
    assert_equal true, result["missing"]
    assert_equal({}, result["parts"])
  end

  def test_unresolved_cn_class_is_reported
    with_registry({"ghost" => <<~TSX}) do |reference|
      function DialogGhost({ className, ...props }: React.ComponentProps<"div">) {
        return <div data-slot="dialog-ghost" className={cn("cn-dialog-ghost flex", className)} {...props} />
      }
    TSX
      result = reference.for("ghost")
      assert_equal ["cn-dialog-ghost"], result["unresolved"]
      assert_equal ["flex"], result["parts"]["dialog-ghost"]["effective"]
    end
  end

  def test_conditional_and_template_class_names_are_warned_not_dropped_silently
    with_registry({"cond" => <<~TSX}) do |reference|
      function Cond({ className, open, ...props }: React.ComponentProps<"div">) {
        return (
          <div
            data-slot="cond"
            className={cn("cn-dialog-header flex", open && "block", `gap-${open}`, className)}
            {...props}
          />
        )
      }
    TSX
      result = reference.for("cond")
      assert_includes result["parts"]["cond"]["effective"], "flex"
      assert_equal 2, result["warnings"].count { |w| w.start_with?("cond (Cond)") }
    end
  end

  def test_nested_selector_for_a_cn_class_is_reported
    css = ".style-vega {\n  .cn-nest {\n    @apply flex;\n    &:hover {\n      @apply underline;\n    }\n  }\n}\n"
    with_registry({"nest" => %(function Nest({ className }) {\n  return <div data-slot="nest" className={cn("cn-nest", className)} />\n}\n)}, css: css) do |reference|
      result = reference.for("nest")
      assert_equal ["flex"], result["parts"]["nest"]["effective"]
      assert(result["warnings"].any? { |w| w.include?("non-plain selector") && w.include?("&:hover") })
    end
  end

  def test_cli_reference_command_is_registered
    assert ShadcnAudit::CLI::COMMANDS.key?("reference")
  end

  private

  def with_registry(files, css: ".style-vega {\n}\n")
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p("#{dir}/bases/base/ui")
      FileUtils.mkdir_p("#{dir}/styles")
      File.write("#{dir}/styles/style-vega.css", css)
      files.each { |name, tsx| File.write("#{dir}/bases/base/ui/#{name}.tsx", tsx) }
      yield ShadcnAudit::Reference.new(registry_dir: dir)
    end
  end
end
