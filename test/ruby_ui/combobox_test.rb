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
end
