# frozen_string_literal: true

require "test_helper"

class RubyUI::ComboboxTest < ComponentTest
  def test_render_with_radio_items
    output = phlex do
      RubyUI.Combobox(multiple: true, term: "frameworks") do
        RubyUI.ComboboxTrigger placeholder: "Select your framework"

        RubyUI.ComboboxPopover do
          RubyUI.ComboboxSearchInput(placeholder: "Type the framework name")

          RubyUI.ComboboxList do
            RubyUI.ComboboxEmptyState { "No results" }

            RubyUI.ComboboxListGroup label: "Ruby" do
              RubyUI.ComboboxItem do
                RubyUI.ComboboxRadio(name: "Rails", value: "rails")
              end
              RubyUI.ComboboxItem do
                RubyUI.ComboboxRadio(name: "Hanami", value: "hanami")
              end
            end

            RubyUI.ComboboxItem do
              RubyUI.ComboboxRadio(name: "Lucky", value: "lucky")
            end
            RubyUI.ComboboxItem do
              RubyUI.ComboboxRadio(name: "Kemal", value: "kemal")
            end
          end
        end
      end
    end

    assert_match(/Hanami/, output)
  end

  def test_render_with_checkbox_items
    output = phlex do
      RubyUI.Combobox(multiple: true, term: "frameworks") do
        RubyUI.ComboboxTrigger placeholder: "Select your framework"

        RubyUI.ComboboxPopover do
          RubyUI.ComboboxSearchInput(placeholder: "Type the framework name")

          RubyUI.ComboboxList do
            RubyUI.ComboboxEmptyState { "No results" }

            RubyUI.ComboboxListGroup label: "Ruby" do
              RubyUI.ComboboxItem do
                RubyUI.ComboboxCheckbox(name: "Rails", value: "rails")
              end
              RubyUI.ComboboxItem do
                RubyUI.ComboboxCheckbox(name: "Hanami", value: "hanami")
              end
            end

            RubyUI.ComboboxItem do
              RubyUI.ComboboxCheckbox(name: "Lucky", value: "lucky")
            end
            RubyUI.ComboboxItem do
              RubyUI.ComboboxCheckbox(name: "Kemal", value: "kemal")
            end
          end
        end
      end
    end

    assert_match(/Hanami/, output)
  end

  def test_combobox_item_renders_indicator
    output = phlex { RubyUI.ComboboxItem { RubyUI.ComboboxRadio(name: "x", value: "1") } }
    assert_match(/peer-checked:opacity-100/, output)
    assert_match(/sr-only/, output)
    assert_match(/peer/, output)
  end

  def test_combobox_radio_is_peer_sr_only
    output = phlex { RubyUI.ComboboxRadio(name: "x", value: "1") }
    assert_match(/\bpeer\b/, output)
    assert_match(/sr-only/, output)
    refute_match(/border-primary/, output)
    refute_match(/rounded-full/, output)
  end

  def test_combobox_checkbox_is_peer_sr_only
    output = phlex { RubyUI.ComboboxCheckbox(name: "x", value: "1") }
    assert_match(/\bpeer\b/, output)
    assert_match(/sr-only/, output)
    refute_match(/border-primary/, output)
    refute_match(/rounded-sm border/, output)
  end

  def test_combobox_item_indicator_renders_check_svg
    output = phlex { RubyUI.ComboboxItemIndicator() }
    assert_match(/peer-checked:opacity-100/, output)
    assert_match(/opacity-0/, output)
    assert_match(/M20 6 9 17l-5-5/, output)
  end

  def test_combobox_badge_trigger_renders_targets
    output = phlex { RubyUI.ComboboxBadgeTrigger() }
    assert_match(/badgeContainer/, output)
    assert_match(/badgeInput/, output)
    assert_match(/openPopover/, output)
  end

  def test_combobox_badge_renders_span
    output = phlex { RubyUI.ComboboxBadge { "Item" } }
    assert_match(/bg-secondary/, output)
    assert_match(/Item/, output)
    assert_match(/<span/, output)
  end

  def test_combobox_clear_button_renders
    output = phlex { RubyUI.ComboboxClearButton() }
    assert_match(/clearAll/, output)
    assert_match(/\bhidden\b/, output)
    assert_match(/clearButton/, output)
  end

  def test_combobox_item_has_hover_state
    output = phlex { RubyUI.ComboboxItem { RubyUI.ComboboxRadio(name: "x", value: "1") } }
    assert_match(/hover:bg-accent/, output)
  end

  def test_combobox_item_has_keyboard_highlight
    output = phlex { RubyUI.ComboboxItem { RubyUI.ComboboxRadio(name: "x", value: "1") } }
    assert_match(/aria-\[current=true\]:bg-accent/, output)
  end

  def test_combobox_item_has_disabled_state
    output = phlex { RubyUI.ComboboxItem { RubyUI.ComboboxRadio(name: "x", value: "1") } }
    assert_match(/has-\[input:disabled\]:opacity-50/, output)
  end

  def test_combobox_toggle_all_checkbox_is_peer_sr_only
    output = phlex { RubyUI.ComboboxToggleAllCheckbox() }
    assert_match(/\bpeer\b/, output)
    assert_match(/sr-only/, output)
  end

  def test_combobox_input_trigger_renders
    output = phlex { RubyUI.ComboboxInputTrigger(placeholder: "Pick one") }
    assert_match(/inputTrigger/, output)        # inputTrigger target on input
    assert_match(/trigger/, output)             # trigger target on wrapper
    assert_match(/Pick one/, output)            # placeholder
    assert_match(/openPopover/, output)         # focus action
    assert_match(/filterItems/, output)         # keyup action
    assert_match(/path.*d="m6 9 6 6 6-6"/, output) # chevron-down SVG present
  end

  def test_combobox_input_trigger_invalid_state
    output = phlex { RubyUI.ComboboxInputTrigger(aria: {invalid: "true"}, placeholder: "Pick") }
    assert_match(/aria-invalid.*true|invalid.*true/, output)
    assert_match(/aria-invalid:border-destructive/, output)
  end

  def test_combobox_clear_button_is_subtle
    output = phlex { RubyUI.ComboboxClearButton() }
    assert_match(/text-muted-foreground/, output)
    assert_match(/focus-visible:ring-2/, output)
  end

  def test_combobox_badge_trigger_input_has_no_border
    output = phlex { RubyUI.ComboboxBadgeTrigger(placeholder: "Select") }
    assert_match(/border-0/, output)
  end

  def test_combobox_badge_trigger_clear_button_prop
    output = phlex { RubyUI.ComboboxBadgeTrigger(clear_button: true) }
    assert_match(/clearButton/, output)
    assert_match(/clearAll/, output)
  end

  def test_combobox_badge_trigger_no_clear_button_by_default
    output = phlex { RubyUI.ComboboxBadgeTrigger() }
    refute_match(/clearButton/, output)
  end

  def test_combobox_badge_trigger_no_chevron
    output = phlex { RubyUI.ComboboxBadgeTrigger() }
    refute_match(/chevron|m6 9 6 6 6-6/, output)
  end

  def test_combobox_trigger_chevron_down
    output = phlex { RubyUI.ComboboxTrigger(placeholder: "Pick") }
    assert_match(/m6 9 6 6 6-6/, output)
  end

  def test_combobox_trigger_placeholder_muted
    output = phlex { RubyUI.ComboboxTrigger(placeholder: "Pick") }
    assert_match(/text-muted-foreground/, output)
  end

  def test_combobox_trigger_chevron_hover_effect
    output = phlex { RubyUI.ComboboxTrigger(placeholder: "Pick") }
    assert_match(/hover:bg-muted/, output)
    assert_match(/size-6/, output)
    assert_match(/rounded-sm/, output)
  end

  def test_combobox_input_trigger_chevron_hover_effect
    output = phlex { RubyUI.ComboboxInputTrigger(placeholder: "Pick") }
    assert_match(/hover:bg-muted/, output)
    assert_match(/size-6/, output)
    assert_match(/rounded-sm/, output)
  end

  def test_combobox_input_trigger_no_inner_padding
    output = phlex { RubyUI.ComboboxInputTrigger(placeholder: "Pick") }
    assert_match(/px-0/, output)
  end

  def test_combobox_keyboard_actions_on_controller
    output = phlex { RubyUI.Combobox { "" } }
    assert_match(/keydown\.down/, output)
    assert_match(/keydown\.up/, output)
    assert_match(/keydown\.enter/, output)
    assert_match(/keydown\.esc/, output)
  end

  def test_combobox_input_trigger_focusin_action
    output = phlex { RubyUI.ComboboxInputTrigger(placeholder: "Pick") }
    assert_match(/focusin->ruby-ui--combobox#openPopover/, output)
  end

  def test_combobox_item_no_selected_background
    output = phlex { RubyUI.ComboboxItem { RubyUI.ComboboxRadio(name: "x", value: "1") } }
    refute_match(/has-\[:checked\]:bg-accent/, output)
  end

  def test_combobox_item_no_ring_on_current
    output = phlex { RubyUI.ComboboxItem { RubyUI.ComboboxRadio(name: "x", value: "1") } }
    refute_match(/aria-\[current=true\]:ring\b/, output)
  end

  def test_combobox_popover_no_autofocus
    output = phlex { RubyUI.ComboboxPopover { "" } }
    refute_match(/autofocus/, output)
  end
end
