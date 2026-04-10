# frozen_string_literal: true

module RubyUI
  class AlertTitle
    include ComponentBase

    private

    def default_attrs
      {class: "mb-1 font-medium leading-none tracking-tight"}
    end
  end
end
