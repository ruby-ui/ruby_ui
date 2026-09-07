module Probes
  # SelectContent, TooltipContent and DatePicker mint a DOM id with
  # SecureRandom.hex(4) and point other attributes at it.
  class WithId < RubyUI::Base
    attr_reader :id

    def initialize(**attrs)
      @id = "content#{SecureRandom.hex(4)}"
      super
    end

    private

    def default_attrs
      {id: @id}
    end
  end
end
