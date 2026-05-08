# frozen_string_literal: true

module LruRedux
  module TTL
    class ThreadSafeCache < Cache
      include ::LruRedux::Util::SafeSync
    end
  end
end
