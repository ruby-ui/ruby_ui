# frozen_string_literal: true

require "test_helper"

class RubyUI::FormTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Form do
        RubyUI.FormField do
          RubyUI.FormFieldLabel { "Label" }
          RubyUI.Input(placeholder: "Joel Drapper", required: true, minlength: "3") { "Joel Drapper" }
          RubyUI.FormFieldHint()
          RubyUI.FormFieldError()
        end
      end
    end

    assert_match(/Joel/, output)
  end
end
