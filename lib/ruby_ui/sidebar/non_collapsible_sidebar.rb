# frozen_string_literal: true

module RubyUI
  class NonCollapsibleSidebar
    include ComponentBase

    private

    def default_attrs
      {class: "flex h-full w-[var(--sidebar-width)] flex-col bg-sidebar text-sidebar-foreground"}
    end
  end
end
