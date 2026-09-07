# frozen_string_literal: true

require "securerandom"

module Gate
  # The gate's copy of the pin in gem/test/golden/harness.rb. TooltipContent,
  # SelectContent and DatePicker mint DOM ids with SecureRandom.hex(4); while a
  # scenario renders, hex returns a counter that restarts per render, so the
  # values match the 1.6 snapshots and the id -> aria/for references stay
  # checkable. Only `hex` is pinned: no gate component reaches for `rand`.
  module Harness
    class << self
      def active?
        @active == true
      end

      def render
        @active = true
        @hex_calls = 0
        yield
      ensure
        @active = false
      end

      def next_hex(bytes)
        (@hex_calls += 1).to_s(16).rjust(bytes * 2, "0")
      end
    end
  end

  module DeterministicSecureRandom
    def hex(bytes = 16)
      Gate::Harness.active? ? Gate::Harness.next_hex(bytes) : super
    end
  end
end

SecureRandom.singleton_class.prepend(Gate::DeterministicSecureRandom)
