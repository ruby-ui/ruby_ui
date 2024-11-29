# frozen_string_literal: true

require "test_helper"

class RubyUI::ComboboxTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Combobox(multiple: true, term: "frameworks") do
        RubyUI.ComboboxInput(name: "multiple")

        RubyUI.ComboboxTrigger placeholder: "Select your framework"

        RubyUI.ComboboxDialog do
          RubyUI.ComboboxSearchInput(placeholder: "Type the framework name")

          RubyUI.ComboboxDatalist do
            RubyUI.ComboboxEmptyState { "No results" }

            RubyUI.ComboboxOptgroup label: "Ruby" do
              RubyUI.ComboboxOption(value: "rails") { "Rails" }
              RubyUI.ComboboxOption(value: "hanami") { "Hanami" }
            end

            RubyUI.ComboboxOptgroup label: "Crystal" do
              RubyUI.ComboboxOption(value: "lucky", selected: true) { "Lucky" }
              RubyUI.ComboboxOption(value: "kemal") { "Kemal" }
            end

            RubyUI.ComboboxOptgroup label: "Others" do
              RubyUI.ComboboxOption(value: "django") { "Django" }
              RubyUI.ComboboxOption(value: "laravel") { "Laravel" }
            end

            RubyUI.ComboboxOption(value: "spring") { "Spring" }
            RubyUI.ComboboxOption(value: "vraptor") { "VRaptor" }
          end
        end
      end
    end

    assert_match(/Hanami/, output)
  end
end
