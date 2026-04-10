# frozen_string_literal: true

module RubyUI
  class Card
    include ComponentBase

    private

    def default_attrs
      {class: "rounded-xl border bg-background shadow"}
    end
  end
end
