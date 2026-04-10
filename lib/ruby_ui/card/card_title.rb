# frozen_string_literal: true

module RubyUI
  class CardTitle
    include ComponentBase

    private

    def default_attrs
      {class: "font-semibold leading-none tracking-tight"}
    end
  end
end
