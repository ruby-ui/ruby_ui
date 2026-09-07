module Probes
  # SelectValue's 2.0 shape (plan §2 item 7): caller content or a placeholder.
  class Fallback < RubyUI::Base
    attr_reader :placeholder

    def initialize(placeholder:, **attrs)
      @placeholder = placeholder
      super(**attrs)
    end
  end
end
