# frozen_string_literal: true

module RubyUI
  class DrawerDescription < Base
    def view_template(&)
      p(**attrs, &)
    end

    private

    def default_attrs
      {
        class: "text-sm text-muted-foreground",
        data: {ruby_ui__drawer_content_target: "description"}
      }
    end
  end
end
