# frozen_string_literal: true

require "test_helper"

class RubyUI::ComboboxTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
      RubyUI.Combobox do
        RubyUI.ComboboxInput()
        RubyUI.ComboboxTrigger do
          RubyUI.ComboboxValue(placeholder: "Select event...")
        end
        RubyUI.ComboboxContent do
          RubyUI.ComboboxSearchInput(placeholder: "Search event...")
          RubyUI.ComboboxList do
            RubyUI.ComboboxEmpty { "No results found." }
            RubyUI.ComboboxGroup(heading: "Suggestions") do
              RubyUI.ComboboxItem(value: "railsworld") do |item|
                item.span { "Rails World" }
              end
              RubyUI.ComboboxItem(value: "tropicalrb") do |item|
                item.span { "Tropical.rb" }
              end
              RubyUI.ComboboxItem(value: "friendly.rb") do |item|
                item.span { "Friendly.rb" }
              end
            end

            RubyUI.ComboboxSeparator()

            RubyUI.ComboboxGroup(heading: "Others") do
              RubyUI.ComboboxItem(value: "railsconf") do |item|
                item.span { "RailsConf" }
              end
              RubyUI.ComboboxItem(value: "euruko") do |item|
                item.span { "Euruko" }
              end
              RubyUI.ComboboxItem(value: "rubykaigi") do |item|
                item.span { "RubyKaigi" }
              end
            end
          end
        end
      end
    end

    assert_match(/Tropical.rb/, output)
  end
end
