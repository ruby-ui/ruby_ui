# frozen_string_literal: true

module RubyUI
  class AccordionIcon
    include ComponentBase

    private

    def default_attrs
      {
        class: "opacity-50",
        data: {ruby_ui__accordion_target: "icon"}
      }
    end
  end
end
