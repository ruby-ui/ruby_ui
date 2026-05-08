# frozen_string_literal: true

module LruRedux
  class ThreadSafeCache < Cache
    include ::LruRedux::Util::SafeSync
  end
end
