# frozen_string_literal: true

module RubyUI
  class AlertDescription
    include ComponentBase

    private

    def default_attrs
      {class: "text-sm [&_p]:leading-relaxed"}
    end
  end
end
