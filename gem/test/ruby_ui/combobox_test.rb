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

  def test_combobox_item_renders_expected_role_and_state_classes
    output = phlex { RubyUI.ComboboxItem { RubyUI.ComboboxRadio(name: "x", value: "1") } }
    assert_match(/role="option"/, output)
    assert_match(/has-\[:checked\]:bg-accent/, output)
    assert_match(/aria-\[current=true\]:ring/, output)
  end

  def test_combobox_radio_renders_styled_input
    output = phlex { RubyUI.ComboboxRadio(name: "x", value: "1") }
    assert_match(/rounded-full/, output)
    assert_match(/border-primary/, output)
    assert_match(/checked:bg-primary/, output)
  end

  def test_combobox_checkbox_renders_styled_input
    output = phlex { RubyUI.ComboboxCheckbox(name: "x", value: "1") }
    assert_match(/\bpeer\b/, output)
    assert_match(/rounded-sm border/, output)
    assert_match(/checked:bg-primary/, output)
  end

  def test_combobox_checkbox_wires_checkbox_group_and_form_field
    output = phlex { RubyUI.ComboboxCheckbox(name: "x", value: "1") }
    assert_match(/data-ruby-ui--checkbox-group-target="checkbox"/, output)
    assert_match(/data-ruby-ui--form-field-target="input"/, output)
    assert_match(/change->ruby-ui--checkbox-group#onChange/, output)
    assert_match(/change->ruby-ui--form-field#onInput/, output)
    assert_match(/invalid->ruby-ui--form-field#onInvalid/, output)
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
    assert_match(/has-disabled:opacity-50/, output)
  end

  def test_combobox_toggle_all_checkbox_renders_styled_input
    output = phlex { RubyUI.ComboboxToggleAllCheckbox() }
    assert_match(/\bpeer\b/, output)
    assert_match(/rounded-sm border/, output)
    assert_match(/change->ruby-ui--combobox#toggleAllItems/, output)
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

  def test_combobox_trigger_sets_placeholder_data
    output = phlex { RubyUI.ComboboxTrigger(placeholder: "Pick") }
    assert_match(/data-placeholder="Pick"/, output)
  end

  def test_combobox_trigger_uses_toggle_action
    output = phlex { RubyUI.ComboboxTrigger(placeholder: "Pick") }
    assert_match(/ruby-ui--combobox#togglePopover/, output)
    assert_match(/h-4 w-4/, output)
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
    output = phlex { RubyUI.ComboboxPopover { "" } }
    assert_match(/keydown\.down/, output)
    assert_match(/keydown\.up/, output)
    assert_match(/keydown\.enter/, output)
  end

  def test_combobox_input_trigger_focusin_action
    output = phlex { RubyUI.ComboboxInputTrigger(placeholder: "Pick") }
    assert_match(/focusin->ruby-ui--combobox#openPopover/, output)
  end

  def test_combobox_item_has_selected_background
    output = phlex { RubyUI.ComboboxItem { RubyUI.ComboboxRadio(name: "x", value: "1") } }
    assert_match(/has-\[:checked\]:bg-accent/, output)
  end

  def test_combobox_item_has_ring_on_current
    output = phlex { RubyUI.ComboboxItem { RubyUI.ComboboxRadio(name: "x", value: "1") } }
    assert_match(/aria-\[current=true\]:ring\b/, output)
  end

  def test_combobox_popover_has_autofocus
    output = phlex { RubyUI.ComboboxPopover { "" } }
    assert_match(/autofocus/, output)
  end

  # The browser's light dismiss hides an auto popover before any exit animation can run.
  def test_combobox_popover_is_a_manual_popover
    output = phlex { RubyUI.ComboboxPopover { "options" } }

    assert_match(/popover="manual"/, output)
    refute_match(/role="popover"/, output)
  end

  # data-state is set by the controller on open; rendering it closed would start an exit run.
  def test_combobox_popover_renders_without_state
    output = phlex { RubyUI.ComboboxPopover { "options" } }

    refute_match(/data-state/, output)
    refute_match(/data-side/, output)
  end

  def test_combobox_popover_animates_open_and_closed
    output = phlex { RubyUI.ComboboxPopover { "options" } }

    assert_match(/data-\[state=open\]:animate-in/, output)
    assert_match(/data-\[state=open\]:fade-in-0/, output)
    assert_match(/data-\[state=open\]:zoom-in-95/, output)
    assert_match(/data-\[state=closed\]:animate-out/, output)
    assert_match(/data-\[state=closed\]:fade-out-0/, output)
    assert_match(/data-\[state=closed\]:zoom-out-95/, output)
    assert_match(/\bduration-100\b/, output)
  end

  # hidePopover() lands a frame after the animation ends; without a forwards fill mode that frame flashes.
  def test_combobox_popover_holds_the_last_frame_of_the_exit_animation
    output = phlex { RubyUI.ComboboxPopover { "options" } }

    assert_match(/data-\[state=closed\]:fill-mode-forwards/, output)
  end

  def test_combobox_popover_slides_in_from_the_trigger_side
    output = phlex { RubyUI.ComboboxPopover { "options" } }

    assert_match(/data-\[side=bottom\]:slide-in-from-top-2/, output)
    assert_match(/data-\[side=top\]:slide-in-from-bottom-2/, output)
    assert_match(/data-\[side=left\]:slide-in-from-right-2/, output)
    assert_match(/data-\[side=right\]:slide-in-from-left-2/, output)
  end

  def test_combobox_popover_keeps_positioning_classes
    output = phlex { RubyUI.ComboboxPopover { "options" } }

    assert_match(/inset-auto m-0 absolute/, output)
  end

  def test_combobox_owns_outside_click_and_escape
    output = phlex { RubyUI.Combobox { "" } }

    assert_match(/click@window->ruby-ui--combobox#handleOutsideClick/, output)
    assert_match(/keydown\.esc@window->ruby-ui--combobox#handleEscape/, output)
  end
end
