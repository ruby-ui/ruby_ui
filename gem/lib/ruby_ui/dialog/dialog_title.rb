# frozen_string_literal: true

module RubyUI
  class DialogTitle < Base
    def view_template(&)
      h2(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "font-heading leading-none font-medium",
        data_ruby_ui__dialog_target: "title"
      }
    end
  end
end
