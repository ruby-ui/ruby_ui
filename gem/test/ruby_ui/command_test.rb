# frozen_string_literal: true

require "test_helper"

class RubyUI::CommandTest < ComponentTest
  def test_inline_command_parts
    output = phlex do
      RubyUI.Command do
        RubyUI.CommandInput(placeholder: "Type a command or search...")
        RubyUI.CommandList do
          RubyUI.CommandEmpty { "No results found." }
          RubyUI.CommandGroup(title: "Suggestions") do
            RubyUI.CommandItem { "Calendar" }
            RubyUI.CommandItem(value: "Calculator", keywords: ["math", "sum"]) { "Calculator" }
          end
          RubyUI.CommandSeparator()
          RubyUI.CommandGroup(title: "Settings") do
            RubyUI.CommandItem(value: "Profile", href: "/profile") do
              RubyUI.CommandShortcut { "⌘P" }
            end
          end
        end
      end
    end

    assert_match(/data-slot="command"[^>]*data-controller="ruby-ui--command"|data-controller="ruby-ui--command"[^>]*data-slot="command"/, output)
    assert_match(/data-ruby-ui--command-loop-value="false"/, output)
    assert_match(/role="combobox"/, output)
    assert_match(/aria-expanded="true"/, output)
    assert_match(/aria-autocomplete="list"/, output)
    assert_match(/role="listbox"/, output)
    assert_match(/data-slot="command-empty"[^>]*hidden|hidden[^>]*data-slot="command-empty"/, output)
    assert_match(/data-slot="command-group-heading"/, output)
    assert_match(/role="group"/, output)
    assert_match(/role="separator"/, output)
    assert_match(/data-slot="command-shortcut"/, output)
    assert_match(/data-keywords="math sum"/, output)
    assert_match(/data-href="\/profile"/, output)
    assert_equal 3, output.scan('role="option"').size
    assert_equal 3, output.scan('aria-selected="false"').size
    refute_match(/<a /, output)
  end

  def test_loop
    output = phlex { RubyUI.Command(loop: true) { "" } }

    assert_match(/data-ruby-ui--command-loop-value="true"/, output)
  end

  def test_disabled_item
    output = phlex { RubyUI.CommandItem(disabled: true) { "Calculator" } }

    assert_match(/aria-disabled="true"/, output)
    assert_match(/data-disabled="true"/, output)
  end

  def test_dialog_uses_native_dialog_with_sr_only_title
    output = phlex do
      RubyUI.CommandDialog do
        RubyUI.CommandDialogTrigger do
          RubyUI.Button(variant: :outline) { "Search" }
        end
        RubyUI.CommandDialogContent do
          RubyUI.Command do
            RubyUI.CommandInput()
            RubyUI.CommandList do
              RubyUI.CommandItem { "Calendar" }
            end
          end
        end
      end
    end

    assert_match(/data-controller="ruby-ui--dialog"/, output)
    assert_match(/<dialog /, output)
    assert_match(/top-1\/3/, output)
    assert_match(/translate-y-0/, output)
    assert_match(/class="sr-only"/, output)
    assert_match(/Command Palette/, output)
    assert_match(/Search for a command to run\.\.\./, output)
    assert_match(/click->ruby-ui--dialog#open/, output)
    assert_match(/keydown\.ctrl\+k@window->ruby-ui--dialog#open/, output)
    assert_match(/keydown\.meta\+k@window->ruby-ui--dialog#open/, output)
    refute_match(/<span class="sr-only">Close<\/span>/, output)
  end

  def test_dialog_title_description_and_close_button
    output = phlex do
      RubyUI.CommandDialog(title: "Search docs", description: "Find a page", show_close_button: true) do
        RubyUI.CommandDialogTrigger(keybindings: ["keydown.meta+j@window"]) { "Open" }
        RubyUI.CommandDialogContent do
          RubyUI.Command { RubyUI.CommandInput() }
        end
      end
    end

    assert_match(/Search docs/, output)
    assert_match(/Find a page/, output)
    assert_match(/<span class="sr-only">Close<\/span>/, output)
    assert_match(/keydown\.meta\+j@window->ruby-ui--dialog#open/, output)
    refute_match(/keydown\.ctrl\+k/, output)
  end
end
