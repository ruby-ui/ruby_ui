# frozen_string_literal: true

module RubyUI
  class TableFooter
    include ComponentBase

    private

    def default_attrs
      {class: "border-t bg-muted/50 font-medium[&>tr]:last:border-b-0"}
    end
  end
end
