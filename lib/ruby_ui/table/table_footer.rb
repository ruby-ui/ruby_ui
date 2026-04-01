# frozen_string_literal: true

module RubyUI
  class TableFooter < Base
    def view_template(&)
      tfoot(**attrs, &)
    end

    private

    def default_attrs
      {
        class: 'border-t bg-muted/50 font-medium[& amp;>tr]:last:border-b-0'
      }
    end
  end
end
