# frozen_string_literal: true

require "test_helper"

class RubyUI::FormTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Form do
        RubyUI.FormField do
          RubyUI.FormFieldLabel { "Label" }
          RubyUI.Input(placeholder: "Joel Drapper", required: true, minlength: "3") { "Joel Drapper" }
          RubyUI.FormFieldHint()
          RubyUI.FormFieldError()
        end
      end
    end

    assert_match(/Joel/, output)
  end

  def test_form_focuses_first_invalid_control
    output = phlex { RubyUI.Form { "content" } }

    assert_match(/data-controller="ruby-ui--form"/, output)
    assert_match(/data-action="invalid->ruby-ui--form#focusFirstInvalid:capture"/, output)
  end

  def test_form_keeps_author_controller_and_action
    output = phlex { RubyUI.Form(data: {controller: "search", action: "submit->search#go"}) { "content" } }

    assert_match(/data-controller="ruby-ui--form search"/, output)
    assert_match(/invalid->ruby-ui--form#focusFirstInvalid:capture submit->search#go/, output)
  end

  def test_form_field_is_a_group_with_vega_spacing
    output = phlex { RubyUI.FormField { "content" } }

    assert_match(/<div role="group"/, output)
    assert_match(/data-controller="ruby-ui--form-field"/, output)
    assert_match(/group\/field/, output)
    assert_match(/gap-3/, output)
    assert_match(/data-\[invalid=true\]:text-destructive/, output)
  end

  def test_form_field_is_vertical_by_default
    output = phlex { RubyUI.FormField { "content" } }

    assert_match(/data-orientation="vertical"/, output)
    assert_match(/flex-col \*:w-full/, output)
  end

  def test_form_field_horizontal_orientation
    output = phlex { RubyUI.FormField(orientation: :horizontal) { "content" } }

    assert_match(/data-orientation="horizontal"/, output)
    assert_match(/flex-row items-center/, output)
    assert_match(/\*:data-\[slot=field-label\]:flex-auto/, output)
    assert_match(/has-\[>\[data-slot=field-content\]\]:items-start/, output)
    refute_match(/flex-col/, output)
    refute_match(/\*:w-full/, output)
  end

  def test_form_field_responsive_orientation_switches_at_field_group_md
    output = phlex { RubyUI.FormField(orientation: :responsive) { "content" } }

    assert_match(/data-orientation="responsive"/, output)
    assert_match(/flex-col \*:w-full/, output)
    assert_match(/@md\/field-group:flex-row/, output)
  end

  def test_form_field_rejects_unknown_orientation
    assert_raises(ArgumentError) { RubyUI::FormField.new(orientation: :diagonal) }
    assert_raises(ArgumentError) { RubyUI::FormField.new(orientation: nil) }
  end

  def test_form_parts_carry_shadcn_data_slots
    output = phlex do
      RubyUI.FormFieldSet do
        RubyUI.FormFieldLegend { "Legend" }
        RubyUI.FormFieldGroup do
          RubyUI.FormField do
            RubyUI.FormFieldContent do
              RubyUI.FormFieldTitle { "Title" }
              RubyUI.FormFieldLabel { "Label" }
              RubyUI.FormFieldHint { "Hint" }
              RubyUI.FormFieldError()
            end
          end
        end
      end
    end

    %w[field-set field-legend field-group field field-content field-label field-description field-error].each do |slot|
      assert_match(/data-slot="#{slot}"/, output)
    end
  end

  def test_form_field_set_is_a_fieldset
    output = phlex { RubyUI.FormFieldSet { "content" } }

    assert_match(/<fieldset data-slot="field-set"/, output)
    assert_match(/flex flex-col gap-6/, output)
    assert_match(/has-\[>\[data-slot=checkbox-group\]\]:gap-3/, output)
    assert_match(/has-\[>\[data-slot=radio-group\]\]:gap-3/, output)
  end

  def test_form_field_legend_variants
    assert_match(/<legend data-slot="field-legend" data-variant="legend"/, phlex { RubyUI.FormFieldLegend { "L" } })
    assert_match(/data-variant="label"/, phlex { RubyUI.FormFieldLegend(variant: :label) { "L" } })
    assert_raises(ArgumentError) { RubyUI::FormFieldLegend.new(variant: :title) }
    assert_raises(ArgumentError) { RubyUI::FormFieldLegend.new(variant: nil) }
  end

  def test_form_field_group_is_the_container_for_responsive_fields
    output = phlex { RubyUI.FormFieldGroup { "content" } }

    assert_match(/group\/field-group @container\/field-group/, output)
    assert_match(/gap-7/, output)
  end

  def test_form_field_title_shares_the_label_slot
    output = phlex { RubyUI.FormFieldTitle { "Title" } }

    assert_match(/<div data-slot="field-label"/, output)
    assert_match(/font-medium/, output)
  end

  def test_form_field_separator_with_and_without_content
    with_content = phlex { RubyUI.FormFieldSeparator { "Or" } }
    without_content = phlex { RubyUI.FormFieldSeparator() }

    assert_match(/role="separator"/, with_content)
    assert_match(/data-content="true"/, with_content)
    assert_match(%r{<span data-slot="field-separator-content"[^>]*>Or</span>}, with_content)
    assert_match(/data-content="false"/, without_content)
    refute_match(/<span/, without_content)
  end

  def test_form_field_label_becomes_a_card_around_a_field
    output = phlex { RubyUI.FormFieldLabel { "Label" } }

    assert_match(/has-\[>\[data-slot=field\]\]:border/, output)
    assert_match(/has-checked:bg-primary\/5/, output)
  end

  def test_form_field_error_renders_one_error_as_text
    output = phlex { RubyUI.FormFieldError(errors: ["can't be blank"]) }

    assert_match(%r{<div role="alert"[^>]*>can&#39;t be blank</div>}, output)
    refute_match(/<ul/, output)
  end

  def test_form_field_error_renders_many_errors_as_list_without_duplicates
    error = Struct.new(:message).new("is invalid")
    output = phlex { RubyUI.FormFieldError(errors: ["is too short", error, "is too short"]) }

    assert_match(/<ul class="ml-4 flex list-disc flex-col gap-1">/, output)
    assert_equal 2, output.scan("<li>").size
    assert_match(%r{<li>is invalid</li>}, output)
  end

  def test_form_field_error_drops_blank_messages
    output = phlex { RubyUI.FormFieldError(errors: ["  ", "", "is invalid"]) }

    assert_match(%r{<div role="alert"[^>]*>is invalid</div>}, output)
  end

  def test_form_field_error_block_wins_over_errors
    output = phlex { RubyUI.FormFieldError(errors: ["ignored"]) { "From block" } }

    assert_match(/From block/, output)
    refute_match(/ignored/, output)
  end

  def test_form_field_error_without_errors_is_empty
    output = phlex { RubyUI.FormFieldError(errors: []) }

    assert_match(%r{<div role="alert"[^>]*></div>}, output)
  end

  def test_form_field_label_dims_through_disabled_field
    output = phlex { RubyUI.FormFieldLabel(for: "email") { "Email" } }

    assert_match(/for="email"/, output)
    assert_match(/leading-snug/, output)
    assert_match(/group-data-\[disabled=true\]\/field:opacity-50/, output)
    refute_match(/opacity-70/, output)
  end

  def test_form_field_hint_is_a_controller_target
    output = phlex { RubyUI.FormFieldHint { "Hint" } }

    assert_match(/data-ruby-ui--form-field-target="hint"/, output)
    assert_match(/leading-normal/, output)
    assert_match(/\[&:nth-last-child\(2_of_:not\(\[data-slot=field-error\]:empty\)\):not\(\[data-variant=legend\]\+\*\)\]:-mt-1/, output)
    refute_match(/ nth-last-2:-mt-1/, output)
  end

  def test_form_field_error_is_an_alert
    output = phlex { RubyUI.FormFieldError { "Error from backend" } }

    assert_match(/<div role="alert"/, output)
    assert_match(/data-ruby-ui--form-field-target="error"/, output)
    assert_match(/font-normal/, output)
    refute_match(/font-medium/, output)
  end
end
