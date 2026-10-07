# frozen_string_literal: true

require "test_helper"

# The gem's tests compile ERB the way a host application will: through
# ReActionView's handler, with Herb validating, under Rails.root. Everything
# the ERB lane and the component layer do later stands on these two facts.
class ErbHarnessTest < Minitest::Test
  def test_erb_is_compiled_by_reactionview_under_rails_root
    # ReActionView registers the handler from the :action_view load hook, which
    # fires when ActionView::Base is autoloaded — touch it here rather than
    # depend on an earlier test having done so.
    assert_kind_of Class, ActionView::Base
    assert_equal ReActionView::Template::Handlers::ERB, ActionView::Template.handler_for_extension(:erb)
    assert_equal File.expand_path("..", __dir__), Rails.root.to_s
    assert_equal "test", Rails.env
  end

  def test_a_malformed_template_is_refused_at_compile_time
    error = assert_raises(ActionView::SyntaxErrorInTemplate) do
      RubyUI::TestApp.view.render(template: "probe/malformed")
    end

    assert_match(/closing tag/i, error.cause.message)
  end
end
