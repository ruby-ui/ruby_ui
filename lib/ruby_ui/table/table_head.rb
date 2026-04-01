# frozen_string_literal: true

module RubyUI
  class TableHead < Base
    def view_template(&)
      th(**attrs, &)
    end

    private

    def default_attrs
      {
        class: 'h-10 px-2 text-left align-middle font-medium text-muted-foreground [&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px]'
      }
    end
  end
end
