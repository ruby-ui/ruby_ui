# frozen_string_literal: true

module RubyUI
  class CollapsibleContent
    include ComponentBase

    private

    def default_attrs
      {
        data: {ruby_ui__collapsible_target: "content"},
        class: "overflow-y-hidden"
      }
    end
  end
end
