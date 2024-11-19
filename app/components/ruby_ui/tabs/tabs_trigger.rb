# frozen_string_literal: true

module RubyUI
  class TabsTrigger < Base
    def initialize(value:, **attrs)
      @value = value
      super(**attrs)
    end

    def view_template(&)
      button(**attrs, &)
    end

    private

    def default_attrs
      {
        type: :button,
        data: {
          ruby_ui__tabs_target: "trigger",
          action: "click->ruby-ui--tabs#show",
          value: @value
        },
        class: "inline-flex items-center justify-center whitespace-nowrap rounded-md px-3 py-1 text-sm font-medium ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 data-[state=active]:bg-background data-[state=active]:text-foreground data-[state=active]:shadow"
      }
    end
  end
end
