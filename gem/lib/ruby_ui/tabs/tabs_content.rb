# frozen_string_literal: true

module RubyUI
  # Base UI's Tabs.Panel (role=tabpanel). Every panel stays in the page; the
  # inactive ones carry the hidden attribute, set by the controller.
  class TabsContent < Base
    def initialize(value:, **attrs)
      @value = value
      super(**attrs)
    end

    def view_template(&)
      div(**attrs, &)
    end

    private

    def default_attrs
      {
        role: "tabpanel",
        tabindex: 0,
        hidden: true,
        data: {
          slot: "tabs-content",
          ruby_ui__tabs_target: :content,
          value: @value
        },
        class: "flex-1 text-sm outline-none"
      }
    end
  end
end
