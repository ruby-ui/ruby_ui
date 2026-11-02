# frozen_string_literal: true

module RubyUI
  # The panel of a Collapsible, after shadcn's CollapsibleContent. It stays in
  # the DOM when closed (hidden attribute), so form fields inside it keep their
  # values and still submit. A custom id: is picked up by the trigger's
  # aria-controls once the controller connects; the server HTML points to the
  # generated id.
  #
  # hidden_until_found: true renders hidden="until-found": the browser's
  # find-in-page (and #:~:text= links) can reach the text and open the panel.
  # A hidden="until-found" panel keeps its padding and border, so put those on
  # an inner element.
  #
  # Animation hooks, as in Base UI: --collapsible-panel-height and
  # --collapsible-panel-width hold the panel size, data-starting-style is set
  # while opening starts and data-ending-style while closing; the panel is
  # hidden once its animations finish. For example:
  #   class: "h-(--collapsible-panel-height) overflow-hidden transition-[height] duration-200
  #           data-starting-style:h-0 data-ending-style:h-0"
  class CollapsibleContent < Base
    def initialize(hidden_until_found: false, **attrs)
      @hidden_until_found = hidden_until_found
      super(**attrs)
    end

    def view_template(&)
      state = context[:ruby_ui_collapsible] || {}
      content_attrs = attrs.dup
      content_attrs[:id] ||= state[:content_id]
      content_attrs[:data] = content_attrs[:data].merge(open: state[:open] || nil, closed: !state[:open] || nil)
      content_attrs[:hidden] = (@hidden_until_found ? "until-found" : true) unless state[:open]
      div(**content_attrs, &)
    end

    private

    def default_attrs
      {
        data: {
          slot: "collapsible-content",
          ruby_ui__collapsible_target: "content",
          hidden_until_found: @hidden_until_found || nil
        }
      }
    end
  end
end
