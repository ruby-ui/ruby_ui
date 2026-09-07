require "test_helper"

# A misconfigured lane would make every other green result meaningless.
class LaneTest < ActiveSupport::TestCase
  test "rails is the charter's pinned ref" do
    assert_equal "8.2.0.alpha", Rails.version
    assert_includes File.read("#{ENV.fetch("BUNDLE_GEMFILE")}.lock"),
      "revision: 60eb5cb72dbf06ef9de39c6786df2f20e838884f"
  end

  test "the :erb handler is the lane's" do
    # ReActionView registers its handler in an on_load(:action_view) hook, i.e.
    # when ActionView::Base loads — before any template compiles, but after a
    # test that only touches ActionView::Template. Load Base first.
    ActionView::Base
    handler = ActionView::Template.handler_for_extension(:erb)

    if Gate.herb?
      assert_equal ReActionView::Template::Handlers::ERB, handler
      assert ReActionView.config.intercept_erb
      assert_equal :raise, ReActionView.config.validation_mode
      assert_equal "0.4.0", ReActionView::VERSION
      assert_equal "0.10.3", Herb::VERSION
    elsif Gate.tags?
      assert_instance_of ActionView::Template::Handlers::ERB, handler
      assert_equal ComponentTagsHerb, ActionView::Template::Handlers::ERB.erb_implementation
      assert_operator ComponentTagsHerb, :<, ActionView::Template::Handlers::ERB::Herb
      assert defined?(Herb::Engine::ComponentTags::Visitor), "herb main's component tags visitor must be loaded"
      assert_includes File.read("#{ENV.fetch("BUNDLE_GEMFILE")}.lock"), "revision: 4269f79f97a7106c610ad2cdf6059b410f5ebeb4"
      assert_not defined?(ReActionView), "the tags lane must not load reactionview"
    else
      assert_instance_of ActionView::Template::Handlers::ERB, handler
      assert_equal ActionView::Template::Handlers::ERB::Erubi, ActionView::Template::Handlers::ERB.erb_implementation
      assert_not defined?(ReActionView), "the erubi lane must not load reactionview"
    end
  end

  test "the layer stays inside its budget" do
    lines = Dir[Rails.root.join("app/components/ruby_ui/*.rb")].sum { |file| File.readlines(file).size }
    assert_operator lines, :<=, 500, "base.rb + attributes.rb exceed the 500-line budget (plan §3)"
  end
end
