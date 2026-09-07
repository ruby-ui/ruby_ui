require "application_system_test_case"

# Behaviour with the 1.6 dialog_controller.js, symlinked and unedited
# (plan §4, Phase 1 acceptance d). Screenshots land in tmp/screenshots/ as
# evidence; nothing compares them.
class DialogTest < ApplicationSystemTestCase
  TRIGGER = "[data-action='click->ruby-ui--dialog#open'] button"
  CLOSE = "dialog button[data-action='click->ruby-ui--dialog#dismiss']"

  # On the spike lane the same behaviour is asserted for the component-tag view.
  SCENARIOS = Gate.tags? ? %w[dialog_default dialog_default_tags] : %w[dialog_default]

  SCENARIOS.each do |scenario|
  test "#{scenario}: trigger opens the dialog, Escape and the close button close it, focus returns to the trigger" do
    visit gate_path(scenario)
    assert_selector TRIGGER, text: "Open Dialog"
    assert_no_selector "dialog[open]"

    find(TRIGGER).click
    assert_selector "dialog[open]", text: "RubyUI to the rescue"
    assert_selector "dialog[open] :focus", visible: :all # focus moved into the dialog
    assert_selector "body.overflow-hidden"
    take_screenshot

    # <dialog>'s close event is dispatched asynchronously after [open] is
    # removed, so every post-close check is a waiting Capybara assertion.
    page.send_keys(:escape)
    assert_no_selector "dialog[open]"
    assert_no_selector "body.overflow-hidden"
    assert_selector "#{TRIGGER}:focus" # focus returned to the trigger

    find(TRIGGER).click
    assert_selector "dialog[open]"
    find(CLOSE).click
    assert_no_selector "dialog[open]"
    assert_no_selector "body.overflow-hidden"
    assert_selector "#{TRIGGER}:focus"
  end
  end
end
