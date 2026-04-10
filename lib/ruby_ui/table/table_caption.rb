# frozen_string_literal: true

module RubyUI
  class TableCaption
    include ComponentBase

    private

    def default_attrs
      {class: "mt-4 text-sm text-muted-foreground"}
    end
  end
end
