# frozen_string_literal: true

module RubyUI
  class TableRow
    include ComponentBase

    private

    def default_attrs
      {class: "border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted"}
    end
  end
end
