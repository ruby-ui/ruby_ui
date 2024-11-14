# frozen_string_literal: true

require "test_helper"

class RubyUI::CodeblockTest < ComponentTest
  def test_render_with_all_items
    code = <<~CODE
      def hello_world
        puts "Hello, world!"
      end
    CODE

    output = phlex do
      RubyUI.Codeblock(code, syntax: :ruby)
    end

    assert_match(/Hello/, output)
  end
end
