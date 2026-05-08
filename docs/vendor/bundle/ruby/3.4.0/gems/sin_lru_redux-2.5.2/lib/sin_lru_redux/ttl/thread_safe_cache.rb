# frozen_string_literal: true

module SinLruRedux
  module TTL
    class ThreadSafeCache < Cache
      include ::SinLruRedux::Util::SafeSync
    end
  end
end
