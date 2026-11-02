# frozen_string_literal: true

require "test_helper"

class RubyUI::CheckboxGroupTest < ComponentTest
  def test_renders_shadcn_checkbox_group_slot
    output = phlex { RubyUI.CheckboxGroup { RubyUI.Checkbox(id: "a") } }

    assert_match(/role="group"/, output)
    assert_match(/data-slot="checkbox-group"/, output)
    assert_match(/data-controller="ruby-ui--checkbox-group"/, output)
    assert_match(/class="group\/field-group @container\/field-group flex w-full flex-col gap-3"/, output)
  end

  def test_not_required_by_default
    output = phlex { RubyUI.CheckboxGroup {} }

    refute_match(/data-required/, output)
  end

  def test_required_kwarg_sets_data_required
    output = phlex { RubyUI.CheckboxGroup(required: true) {} }

    assert_match(/data-required/, output)
  end

  def test_data_required_still_works
    output = phlex { RubyUI.CheckboxGroup(data_required: true) {} }
    assert_match(/data-required/, output)

    output = phlex { RubyUI.CheckboxGroup(data: {required: true}) {} }
    assert_match(/data-required/, output)
  end

  def test_checkbox_revalidates_its_field_on_group_change
    output = phlex { RubyUI.Checkbox(id: "a") }

    assert_match(/ruby-ui--checkbox-group:change-&gt;ruby-ui--form-field#onChange|ruby-ui--checkbox-group:change->ruby-ui--form-field#onChange/, output)
  end

  def test_user_class_merges_over_gap
    output = phlex { RubyUI.CheckboxGroup(class: "gap-6 max-h-40") {} }

    assert_match(/flex-col gap-6 max-h-40/, output)
    refute_match(/gap-3/, output)
  end
end
