# frozen_string_literal: true

module RubyUI
  class TypographyBlockquote < Base
    def view_template(&)
      blockquote(**attrs, &)
    end

    private

    def default_attrs
      {
        class: 'mt-6 border-l-2 pl-6 italic'
      }
    end
  end
end
