# frozen_string_literal: true

require "test_helper"

class RubyUI::ComboboxTest < ComponentTest
  def render_popup(**root)
    phlex do
      RubyUI.Combobox(name: "fruit", id: "fruits", **root) do
        RubyUI.ComboboxTrigger { RubyUI.ComboboxValue(placeholder: "Pick a fruit") }
        RubyUI.ComboboxContent do
          RubyUI.ComboboxInput(placeholder: "Search", show_trigger: false)
          RubyUI.ComboboxEmpty { "No items found." }
          RubyUI.ComboboxList do
            RubyUI.ComboboxGroup(id: "g") do
              RubyUI.ComboboxLabel { "Fruits" }
              RubyUI.ComboboxItem(value: "apple", selected: true) { "Apple" }
              RubyUI.ComboboxItem(value: "banana", disabled: true) { "Banana" }
            end
            RubyUI.ComboboxSeparator()
          end
        end
      end
    end
  end

  def test_root_has_no_role_and_wires_the_controller
    output = render_popup

    assert_match(/<div id="fruits" data-slot="combobox" data-controller="ruby-ui--combobox"/, output)
    refute_match(/<div id="fruits"[^>]*role=/, output)
  end

  def test_trigger_is_an_outline_button_with_combobox_role
    output = render_popup

    assert_match(/role="combobox"/, output)
    assert_match(/aria-haspopup="dialog"/, output)
    refute_match(/aria-controls="fruits-content"/, output)
    assert_match(/aria-expanded="false"/, output)
    assert_match(/border-border bg-background shadow-xs/, output)
    assert_match(/font-normal/, output)
  end

  def test_content_is_a_manual_popover_dialog_with_vega_classes
    output = render_popup

    assert_match(/id="fruits-content" role="dialog" popover="manual" data-slot="combobox-content"/, output)
    assert_match(/data-closed=""/, output)
    assert_match(/ring-1 ring-foreground\/10/, output)
    assert_match(/data-open:animate-in/, output)
  end

  def test_content_without_trigger_has_no_dialog_role
    output = phlex do
      RubyUI.Combobox(name: "f", id: "c") do
        RubyUI.ComboboxInput(placeholder: "Pick")
        RubyUI.ComboboxContent { RubyUI.ComboboxList { RubyUI.ComboboxItem(value: "a") { "A" } } }
      end
    end

    refute_match(/role="dialog"/, output)
  end

  def test_content_placement
    output = phlex { RubyUI.ComboboxContent(side: :top, align: :end, side_offset: 10, align_offset: 2) }

    assert_match(/data-preferred-side="top"/, output)
    assert_match(/data-align="end"/, output)
    assert_match(/data-side-offset="10"/, output)
    assert_match(/data-align-offset="2"/, output)
  end

  def test_input_is_a_combobox_controlling_the_list
    output = render_popup

    assert_match(/aria-controls="fruits-list" aria-autocomplete="list" aria-expanded="false" aria-haspopup="listbox" type="text" role="combobox"/, output)
    assert_match(/data-slot="input-group"/, output)
    assert_match(/data-slot="input-group-control"/, output)
  end

  def test_input_trigger_and_clear_buttons
    output = phlex { RubyUI.ComboboxInput(placeholder: "Pick", show_clear: true) }

    assert_match(/data-slot="input-group-button"/, output)
    assert_match(/data-slot="combobox-clear"[^<]*?type="button" hidden aria-label="Clear"/, output)
    # The clear button stays in the tab order (keyboard way to clear).
    refute_match(/data-slot="combobox-clear"[^<]*?tabindex/, output)
    refute_match(/data-slot="button input-group-button"/, output)
  end

  def test_input_without_trigger_keeps_an_empty_addon
    output = phlex { RubyUI.ComboboxInput(show_trigger: false) }

    assert_match(/data-slot="input-group-addon" data-align="inline-end" data-action="click->ruby-ui--combobox#focusInput"><\/div>/, output)
  end

  def test_disabled_root_disables_the_input
    output = phlex do
      RubyUI.Combobox(disabled: true) { RubyUI.ComboboxInput(placeholder: "Pick") }
    end

    assert_match(/data-disabled="true"/, output)
    assert_match(/<input disabled/, output)
  end

  def test_invalid_input_keeps_aria_invalid
    output = phlex { RubyUI.ComboboxInput(aria: {invalid: "true"}) }

    assert_match(/aria-invalid="true"/, output)
  end

  def test_list_is_a_listbox
    output = render_popup

    assert_match(/id="fruits-list" role="listbox" data-slot="combobox-list"/, output)
  end

  def test_multiple_list_is_multiselectable
    output = phlex do
      RubyUI.Combobox(multiple: true) { RubyUI.ComboboxList {} }
    end

    assert_match(/aria-multiselectable="true"/, output)
  end

  def test_item_renders_option_with_hidden_radio
    output = render_popup

    assert_match(/role="option" aria-selected="true" data-slot="combobox-item"/, output)
    assert_match(/<input type="radio" name="fruit" value="apple" checked tabindex="-1" aria-hidden="true" class="sr-only"/, output)
    assert_match(/group-aria-selected\/combobox-item:flex/, output)
  end

  def test_disabled_item
    output = render_popup

    assert_match(/aria-disabled="true"[^>]*data-value="banana"[^>]*data-disabled=""/, output)
    assert_match(/value="banana" disabled/, output)
  end

  def test_multiple_items_use_checkboxes
    output = phlex do
      RubyUI.Combobox(name: "fruits[]", multiple: true) do
        RubyUI.ComboboxItem(value: "apple") { "Apple" }
      end
    end

    assert_match(/<input type="checkbox" name="fruits\[\]" value="apple"/, output)
    assert_match(/ruby-ui--checkbox-group-target="checkbox"/, output)
  end

  def test_required_single_combobox_marks_the_radios
    output = phlex do
      RubyUI.Combobox(name: "fruit", required: true) do
        RubyUI.ComboboxItem(value: "apple") { "Apple" }
      end
    end

    assert_match(/value="apple" required/, output)
  end

  def test_required_multiple_combobox_uses_checkbox_group
    output = phlex do
      RubyUI.Combobox(name: "fruits[]", multiple: true, required: true) do
        RubyUI.ComboboxItem(value: "apple") { "Apple" }
      end
    end

    assert_match(/data-controller="ruby-ui--combobox ruby-ui--checkbox-group" data-required=""/, output)
    refute_match(/value="apple" required/, output)
  end

  def test_required_without_name_raises
    assert_raises(ArgumentError) { RubyUI::Combobox.new(required: true) }
  end

  def test_required_marks_visible_controls
    output = phlex do
      RubyUI.Combobox(name: "f", required: true) do
        RubyUI.ComboboxTrigger { RubyUI.ComboboxValue() }
        RubyUI.ComboboxContent { RubyUI.ComboboxInput(show_trigger: false) }
      end
    end

    assert_equal 2, output.scan('aria-required="true"').size
  end

  def test_group_without_label_has_no_labelledby
    output = phlex do
      RubyUI.ComboboxGroup(id: "g") { RubyUI.ComboboxItem(value: "a") { "A" } }
    end

    refute_match(/aria-labelledby/, output)
  end

  def test_group_uses_the_label_own_id
    output = phlex do
      RubyUI.ComboboxGroup(id: "g") { RubyUI.ComboboxLabel(id: "custom") { "Fruits" } }
    end

    assert_match(/aria-labelledby="custom"/, output)
  end

  def test_chip_remove_is_in_tab_order
    output = phlex { RubyUI.ComboboxChips() }

    refute_match(/data-slot="combobox-chip-remove"[^<]*tabindex/, output)
  end

  def test_item_input_attributes
    output = phlex do
      RubyUI.ComboboxItem(value: "a", input: {data: {value_missing: "Pick one"}}) { "A" }
    end

    assert_match(/data-value-missing="Pick one"/, output)
  end

  def test_group_is_named_by_its_label
    output = render_popup

    assert_match(/aria-labelledby="g-label" role="group"/, output)
    assert_match(/aria-hidden="true" data-slot="combobox-label" class="px-2 py-1.5 text-xs text-muted-foreground" id="g-label"/, output)
  end

  def test_separator_and_empty
    output = render_popup

    assert_match(/role="separator"/, output)
    assert_match(/data-slot="combobox-empty"[^>]*group-data-empty\/combobox-content:flex/, output)
  end

  def test_value_shows_the_placeholder
    output = render_popup

    assert_match(/data-placeholder-text="Pick a fruit" data-placeholder="">Pick a fruit</, output)
  end

  def test_term_value
    output = phlex { RubyUI.Combobox(term: "fruits") {} }

    assert_match(/data-ruby-ui--combobox-term-value="fruits"/, output)
  end

  def test_chips_with_template_and_input
    output = phlex do
      RubyUI.Combobox(name: "f[]", multiple: true, id: "m") do
        RubyUI.ComboboxChips { RubyUI.ComboboxChipsInput(placeholder: "Add") }
      end
    end

    assert_match(/data-slot="combobox-chips"/, output)
    assert_match(/<template data-ruby-ui--combobox-target="chipTemplate"><div data-slot="combobox-chip"/, output)
    assert_match(/data-slot="combobox-chip-remove"/, output)
    assert_match(/aria-controls="m-list"[^>]*role="combobox" placeholder="Add"/, output)
  end

  def test_chips_max
    output = phlex { RubyUI.ComboboxChips(max: 3) }

    assert_match(/data-slot="combobox-chips" data-ruby-ui--combobox-target="chips" data-max="3"/, output)
  end

  def test_chips_without_max_has_no_cap
    output = phlex { RubyUI.ComboboxChips() }

    refute_match(/data-max/, output)
  end

  def test_chips_without_remove
    output = phlex { RubyUI.ComboboxChips(show_remove: false) }

    refute_match(/data-slot="combobox-chip-remove"/, output)
  end

  def test_toggle_all
    output = phlex { RubyUI.ComboboxToggleAll { "Select all" } }

    assert_match(/role="option" aria-selected="false"/, output)
    assert_match(/ruby-ui--combobox-target="toggleAll"/, output)
  end
end
