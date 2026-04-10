# frozen_string_literal: true

module RubyUI
  class InlineCode
    include ComponentBase

    private

    def default_attrs
      {class: "relative rounded bg-muted px-[0.3rem] py-[0.2rem] font-mono text-sm font-semibold"}
    end
  end
end
