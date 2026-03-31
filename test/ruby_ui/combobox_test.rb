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
end
