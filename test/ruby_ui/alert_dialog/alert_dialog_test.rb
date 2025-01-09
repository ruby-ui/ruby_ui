# frozen_string_literal: true

require "test_helper"
require "capybara/minitest"
require_relative "alert_dialog_spec"

class RubyUI::AlertDialogTest < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions
  include Phlex::Testing::ViewHelper

  def setup
    @spec = RubyUI::AlertDialogSpec.new
    Capybara.default_driver = :cuprite
    Capybara.javascript_driver = :cuprite
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def test_render_with_all_items
    rendered_html = phlex_context { @spec.spec(self) }
    
    # Insert the rendered HTML into a test page and wait for it to be ready
    page.driver.browser.execute(<<~JS)
      document.body.innerHTML = `#{rendered_html}`;
      // Ensure Stimulus controllers are connected
      window.Stimulus.application.start()
    JS

    # Add a small wait to ensure the page is ready
    sleep 0.1

    # Test initial state
    refute_selector 'div[role="alertdialog"]', visible: true
    assert_selector '[data-action="click->ruby-ui--alert-dialog#open"] button', text: "Show dialog"

    # Test opening dialog
    find('[data-action="click->ruby-ui--alert-dialog#open"] button').click
    assert_selector 'div[role="alertdialog"]', visible: true

    # Test dialog content
    within 'div[role="alertdialog"]' do
      assert_selector 'h2', text: 'Are you absolutely sure?'
      assert_selector 'p.text-muted-foreground', 
        text: 'This action cannot be undone. This will permanently delete your account and remove your data from our servers.'
      assert_selector 'button[data-action="click->ruby-ui--alert-dialog#dismiss"]', text: 'Cancel'
      assert_selector 'button', text: 'Continue'
    end

    # Test closing dialog
    click_button 'Cancel'
    refute_selector 'div[role="alertdialog"]', visible: true
  end
end
