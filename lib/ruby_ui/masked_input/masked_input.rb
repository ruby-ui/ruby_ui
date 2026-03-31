# frozen_string_literal: true

module RubyUI
  class MaskedInput < Base
    def initialize(save_unmasked: false, **attrs)
      @save_unmasked = save_unmasked
      super(**attrs)
    end

    def view_template
      if @save_unmasked
        Input(type: "text", **attrs.merge(name: "#{attrs[:name]}-masked"))
        input(type: "hidden", name: attrs[:name], value: attrs[:value])
      else
        Input(type: "text", **attrs)
      end
    end

    private

    def default_attrs
      {data: {controller: "ruby-ui--masked-input"}}
    end
  end
end
