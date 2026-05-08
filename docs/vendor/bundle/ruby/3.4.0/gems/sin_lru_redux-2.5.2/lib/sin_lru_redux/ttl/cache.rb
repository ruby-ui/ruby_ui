# frozen_string_literal: true

require_relative '../../lru_redux/ttl/cache'

module SinLruRedux
  module TTL
    class Cache < ::LruRedux::TTL::Cache
    end
  end
end
