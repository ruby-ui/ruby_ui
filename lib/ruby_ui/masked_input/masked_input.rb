# frozen_string_literal: true

module RubyUI
  class MaskedInput
    include ComponentBase

    def initialize(**attrs)
      # Add masked-input controller to user data attrs, then delegate to Input
      user_data = attrs.delete(:data) || {}
      merged_data = {controller: "ruby-ui--masked-input"}.merge(user_data)
      @attrs = RubyUI::Input.new(type: "text", data: merged_data, **attrs).attrs
    end

    def attrs
      @attrs ||= {}
    end
  end
end
