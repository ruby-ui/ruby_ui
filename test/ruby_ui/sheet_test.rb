# frozen_string_literal: true

require "test_helper"

class RubyUI::SheetTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
      RubyUI.Sheet do
        RubyUI.SheetTrigger do
          RubyUI.Button(variant: :outline) { "Open Sheet" }
        end

        RubyUI.SheetContent(class: "sm:max-w-sm") do
          RubyUI.SheetHeader do
            RubyUI.SheetTitle { "Edit profile" }
            RubyUI.SheetDescription { "Make changes to your profile here. Click save when you're done." }
          end
          RubyUI.SheetMiddle do
            RubyUI.Input(placeholder: "Joel Drapper") { "Joel Drapper" }
            RubyUI.Input(placeholder: "joel@drapper.me")

            RubyUI.SheetFooter do
              RubyUI.Button(variant: :outline, data: {action: "click->ruby_ui--sheet-content#close"}) { "Cancel" }
              RubyUI.Button(type: "submit") { "Save" }
            end
          end
        end
      end
    end

    assert_match(/Open Sheet/, output)
  end
end
