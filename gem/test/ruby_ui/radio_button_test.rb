# frozen_string_literal: true

require "test_helper"

class RubyUI::RadioButtonTest < ComponentTest
  def test_renders_a_native_radio_with_data_slot
    output = phlex { RubyUI.RadioButton(id: "default", name: "density", value: "default") }

    assert_match(/<input[^>]*type="radio"/, output)
    assert_match(/data-slot="radio-group-item"/, output)
    assert_match(/name="density"/, output)
    assert_match(/value="default"/, output)
  end

  def test_draws_itself_instead_of_the_forms_plugin
    output = phlex { RubyUI.RadioButton }

    assert_match(/appearance-none/, output)
    assert_match(/border-input/, output)
    assert_match(/bg-transparent/, output)
    assert_match(/dark:bg-input\/30/, output)
    assert_match(/checked:bg-none/, output)
    assert_match(/checked:before:block/, output)
    refute_match(/border-primary rounded-full/, output)
    refute_match(/dark:checked:bg-secondary/, output)
  end

  def test_has_the_vega_focus_and_invalid_styles
    output = phlex { RubyUI.RadioButton }

    assert_match(/focus-visible:ring-ring\/50/, output)
    assert_match(/aria-invalid:border-destructive/, output)
    assert_match(/aria-invalid:checked:border-primary/, output)
  end

  def test_disabled_dims_only_itself
    output = phlex { RubyUI.RadioButton }

    assert_match(/disabled:opacity-50/, output)
    refute_match(/group-has-disabled/, output)
  end

  def test_form_field_label_is_the_field_label_group
    output = phlex { RubyUI.FormFieldLabel(for: "a") { "A" } }

    assert_match(/group\/field-label/, output)
  end

  def test_wires_form_field_validation
    output = phlex { RubyUI.RadioButton(required: true) }

    assert_match(/data-ruby-ui--form-field-target="input"/, output)
    assert_match(/invalid->ruby-ui--form-field#onInvalid/, output)
    assert_match(/required/, output)
  end

  def test_radio_group_renders_a_radiogroup
    output = phlex do
      RubyUI.RadioGroup(aria: {label: "Density"}) do
        RubyUI.RadioButton(name: "density", value: "default")
      end
    end

    assert_match(/<div role="radiogroup"/, output)
    assert_match(/data-slot="radio-group"/, output)
    assert_match(/aria-label="Density"/, output)
    assert_match(/grid w-full gap-3/, output)
    assert_match(/type="radio"/, output)
  end
end
