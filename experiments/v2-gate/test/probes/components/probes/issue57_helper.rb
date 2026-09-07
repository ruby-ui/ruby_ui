module Probes
  module Issue57Helper
    def wrap_with_partial(&block)
      render "probe/wrapper", &block
    end
  end
end
