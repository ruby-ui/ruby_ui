require "test_helper"

# Phase 1 layer probes (plan §4): the shapes the gate components need from the
# layer, each isolated in a throwaway component under test/probes/components.
class LayerProbeTest < ActiveSupport::TestCase
  test "a component can render nothing (DataTablePagination with total <= 1)" do
    assert_equal "", Gate.canonical("probe/rootless_hidden")
    assert_equal <<~HTML, Gate.canonical("probe/rootless_shown")
      <nav class="pager">
        pages
      </nav>
    HTML
  end

  test "attrs are computed with no view context (PaginationItem reads Button.new(...).attrs)" do
    button = RubyUI::Button.new(variant: :outline)

    assert_equal "whitespace-nowrap inline-flex items-center justify-center rounded-md font-medium transition-colors " \
      "disabled:pointer-events-none disabled:opacity-50 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring " \
      "aria-disabled:pointer-events-none aria-disabled:opacity-50 aria-disabled:cursor-not-allowed px-4 py-2 h-9 text-sm " \
      "border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground", button.attrs["class"]
    assert_equal "button", button.attrs["type"]
    assert_raises(ArgumentError) { button.helpers }
  end

  test "caller classes override defaults through tailwind_merge, and nil does not erase a default" do
    assert_equal "inline-block", RubyUI::DialogTrigger.new(class: nil).attrs["class"]
    assert_equal "block", RubyUI::DialogTrigger.new(class: "block").attrs["class"]
    assert_equal({"class" => "inline-block", "data-action" => "click->ruby-ui--dialog#open", "data-x" => "1"},
      RubyUI::DialogTrigger.new(data: {x: 1}).attrs)
  end

  test "content.presence falls back to the placeholder for an empty and a whitespace-only block" do
    placeholder = "<span>\n  Pick one\n</span>\n"

    assert_equal placeholder, Gate.canonical("probe/fallback_empty")
    assert_equal placeholder, Gate.canonical("probe/fallback_whitespace")
    assert_equal "<span>\n  Apple\n</span>\n", Gate.canonical("probe/fallback_text")
  end

  test "a generated id is pinned by the harness and its references line up" do
    assert_equal <<~HTML, Gate.canonical("probe/with_id")
      <div id="content00000001">
        <span aria-controls="content00000001">
          x
        </span>
      </div>
    HTML
  end

  test "a custom element root (turbo-frame)" do
    assert_equal <<~HTML, Gate.canonical("probe/frame")
      <turbo-frame data-controller="ruby-ui--data-table" id="employees">
        <p>
          rows
        </p>
      </turbo-frame>
    HTML
  end

  test "rendering with no request is the 2.0 equivalent of the gem's phlex { } helper" do
    html = Gate.render("gate/dialog_default")

    assert_includes html, 'data-controller="ruby-ui--dialog"'
    assert_not_includes html, "<html", "no layout"

    # A component alone, from Ruby, no view: ActionView's renderable path.
    assert_equal "<button type=\"button\" class=\"#{RubyUI::Button.new.attrs["class"]}\"></button>",
      GateController.render(RubyUI::Button.new, layout: false).strip
  end
end
