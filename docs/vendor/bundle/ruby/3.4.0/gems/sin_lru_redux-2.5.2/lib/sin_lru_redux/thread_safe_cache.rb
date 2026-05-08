# frozen_string_literal: true

module SinLruRedux
  class ThreadSafeCache < Cache
    include ::SinLruRedux::Util::SafeSync
  end
end
