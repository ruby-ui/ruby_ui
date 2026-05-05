# frozen_string_literal: true

module RubyUI
  class SidebarInset < Base
    def view_template(&)
      main(**attrs, &)
    end

    private

    def default_attrs
      {
        class: [
          "relative flex w-full flex-1 flex-col bg-background",
          "md:peer-data-[variant=inset]:m-2",
          "md:peer-data-[state=collapsed]:peer-data-[variant=inset]:ml-2",
          "md:peer-data-[variant=inset]:ml-0 md:peer-data-[variant=inset]:rounded-xl",
          "md:peer-data-[variant=inset]:shadow"
        ]
      }
    end
  end
end
