# frozen_string_literal: true

module RubyUI
  class DrawerTitle < Base
    def view_template(&)
      h2(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "text-lg font-semibold leading-none tracking-tight",
        data: {ruby_ui__drawer_content_target: "title"}
      }
    end
  end
end
