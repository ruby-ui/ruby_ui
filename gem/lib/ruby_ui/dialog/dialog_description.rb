# frozen_string_literal: true

module RubyUI
  class DialogDescription < Base
    def view_template(&)
      p(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "text-sm text-muted-foreground *:[a]:underline *:[a]:underline-offset-3 *:[a]:hover:text-foreground",
        data_ruby_ui__dialog_target: "description"
      }
    end
  end
end
