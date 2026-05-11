# frozen_string_literal: true

module RubyUI
  module MCP
    module Tools
      class Base
        def initialize(registry:)
          @registry = registry
        end

        def call(**args)
          raise NotImplementedError
        end
      end
    end
  end
end
