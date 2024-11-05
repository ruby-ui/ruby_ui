# frozen_string_literal: true

require "test_helper"

class RubyUI::DialogTest < Minitest::Test
  include Phlex::Testing::ViewHelper

  def test_render_with_all_items
    output = phlex_context do
      RubyUI.Dialog do
        RubyUI.DialogTrigger do
          RubyUI.Button { "Open Dialog" }
        end
        RubyUI.DialogContent do
          RubyUI.DialogHeader do
            RubyUI.DialogTitle { "RubyUI to the rescue" }
            RubyUI.DialogDescription { "RubyUI helps you build accessible standard compliant web apps with ease" }
          end
          RubyUI.DialogMiddle do
            RubyUI.AspectRatio(aspect_ratio: "16/9", class: "rounded-md overflow-hidden border") do |aspect|
              aspect.img(
                alt: "Placeholder",
                loading: "lazy",
                src: "https://avatars.githubusercontent.com/u/246692?v=4"
              )
            end
          end
          RubyUI.DialogFooter do
            RubyUI.Button(variant: :outline, data: {action: "click->ruby_ui--dialog#dismiss"}) { "Cancel" }
            RubyUI.Button { "Save" }
          end
        end
      end
    end

    assert_match(/Open Dialog/, output)
  end
end
