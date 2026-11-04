# frozen_string_literal: true

module RubyUI
  class SidebarSeparator < Base
    def view_template(&)
      Separator(**separator_attrs, &)
    end

    private

    # slot! makes Separator replace its own data-slot="separator" instead of
    # joining it. Added after Base's mix, which would strip the bang.
    def separator_attrs
      attrs.merge(data: attrs.fetch(:data, {}).merge(slot!: "sidebar-separator"))
    end

    def default_attrs
      {
        class: "mx-2 w-auto bg-sidebar-border",
        data: {
          sidebar: "separator"
        }
      }
    end
  end
end
