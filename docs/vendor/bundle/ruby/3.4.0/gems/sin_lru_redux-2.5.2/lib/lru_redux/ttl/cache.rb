# frozen_string_literal: true

module LruRedux
  module TTL
    class Cache
      attr_reader :max_size, :ttl, :ignore_nil

      def initialize(*args)
        max_size, ttl, ignore_nil = args

        max_size ||= 1000
        ttl ||= :none
        ignore_nil ||= false

        validate_max_size!(max_size)
        validate_ttl!(ttl)
        validate_ignore_nil!(ignore_nil)

        @max_size = max_size
        @ttl = ttl
        @ignore_nil = ignore_nil
        @data_lru = {}
        @data_ttl = {}
      end

      def max_size=(new_max_size)
        validate_max_size!(new_max_size)

        @max_size = new_max_size
        evict_expired
        evict_excess
      end

      def ttl=(new_ttl)
        validate_ttl!(new_ttl)

        @ttl = new_ttl
        evict_expired
      end

      def ignore_nil=(new_ignore_nil)
        validate_ignore_nil!(new_ignore_nil)

        @ignore_nil = new_ignore_nil
        evict_nil
      end

      def getset(key)
        evict_expired

        key_found = true
        value = @data_lru.delete(key) { key_found = false }

        if key_found
          @data_ttl.delete(key)
          @data_ttl[key] = Time.now.to_f
          @data_lru[key] = value
        else
          result = yield
          store_item(key, result)
          result
        end
      end

      def fetch(key)
        evict_expired

        key_found = true
        value = @data_lru.delete(key) { key_found = false }

        if key_found
          @data_ttl.delete(key)
          @data_ttl[key] = Time.now.to_f
          @data_lru[key] = value
        else
          yield if block_given? # rubocop:disable Style/IfInsideElse
        end
      end

      def [](key)
        evict_expired

        key_found = true
        value = @data_lru.delete(key) { key_found = false }
        return unless key_found

        @data_ttl.delete(key)
        @data_ttl[key] = Time.now.to_f
        @data_lru[key] = value
      end

      def []=(key, val)
        evict_expired

        store_item(key, val)
      end

      def each(&block)
        evict_expired

        @data_lru.to_a.reverse_each(&block)
      end
      alias_method :each_unsafe, :each

      def to_a
        evict_expired

        @data_lru.to_a.reverse
      end

      def values
        evict_expired

        @data_lru.values.reverse
      end

      def delete(key)
        evict_expired

        @data_ttl.delete(key)
        @data_lru.delete(key)
      end
      alias_method :evict, :delete

      def key?(key)
        evict_expired

        @data_lru.key?(key)
      end
      alias_method :has_key?, :key?

      def clear
        @data_ttl.clear
        @data_lru.clear
      end

      def count
        @data_lru.size
      end
      alias_method :length, :count
      alias_method :size, :count

      def expire
        evict_expired
      end

      private

      # For cache validation only, ensure all is valid
      def valid?
        @data_lru.size == @data_ttl.size
      end

      def validate_max_size!(max_size)
        unless max_size.is_a?(Numeric)
          raise ArgumentError.new(<<~ERROR)
            Invalid max_size: #{max_size.inspect}
            max_size must be a number.
          ERROR
        end
        return if max_size >= 1

        raise ArgumentError.new(<<~ERROR)
          Invalid max_size: #{max_size.inspect}
          max_size must be greater than or equal to 1.
        ERROR
      end

      def validate_ttl!(ttl)
        return if ttl == :none

        unless ttl.is_a?(Numeric)
          raise ArgumentError.new(<<~ERROR)
            Invalid ttl: #{ttl.inspect}
            ttl must be a number.
          ERROR
        end
        return if ttl >= 0

        raise ArgumentError.new(<<~ERROR)
          Invalid ttl: #{ttl.inspect}
          ttl must be greater than or equal to 0.
        ERROR
      end

      def validate_ignore_nil!(ignore_nil)
        return if [true, false].include?(ignore_nil)

        raise ArgumentError.new("Invalid ignore_nil: #{ignore_nil.inspect}")
      end

      def evict_excess
        while @data_lru.size > @max_size
          @data_lru.shift
          @data_ttl.shift
        end
      end

      def evict_expired
        return if @ttl == :none

        expiration_threshold = Time.now.to_f - @ttl
        key, time = @data_ttl.first
        until time.nil? || time > expiration_threshold
          @data_lru.delete(key)
          @data_ttl.delete(key)
          key, time = @data_ttl.first
        end
      end

      def evict_nil
        return unless @ignore_nil

        @data_lru.reject! do |key, value|
          if value.nil?
            @data_ttl.delete(key)
            true
          else
            false
          end
        end
      end

      def store_item(key, value)
        @data_lru.delete(key)
        @data_ttl.delete(key)
        if !value.nil? || !@ignore_nil
          @data_lru[key] = value
          @data_ttl[key] = Time.now.to_f
        end
        evict_excess
        value
      end
    end
  end
end
