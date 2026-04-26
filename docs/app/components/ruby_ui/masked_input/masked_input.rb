# frozen_string_literal: true

module RubyUI
  class MaskedInput < Base
    def view_template
      Input(type: "text", **attrs)
    end

    private

    def default_attrs
      {data: {controller: "ruby-ui--masked-input"}}
    end
  end
end
