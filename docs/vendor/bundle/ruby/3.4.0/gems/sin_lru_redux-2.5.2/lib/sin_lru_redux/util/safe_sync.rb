# frozen_string_literal: true

require_relative '../../lru_redux/util/safe_sync'

module SinLruRedux
  module Util
    module SafeSync
      include ::LruRedux::Util::SafeSync
    end
  end
end
