# frozen_string_literal: true

require "securerandom"

module Golden
  # Renders one catalog scenario, and does the two things that stand between
  # "call the component" and "a snapshot that can be committed": pin the
  # components that reach for a random number, and record which component
  # classes a render actually touched.
  module Harness
    # Guard against pinning a range so large that materialising it would be the
    # bug. 1.6 uses a single `rand(50..89)`.
    MAX_PINNED_RANGE = 1_000

    class << self
      def active?
        @active == true
      end

      # Renders through the same path as the `phlex { ... }` helper in
      # test_helper.rb, so a scenario block is written exactly like the body of
      # an existing component test.
      def render(&block)
        @active = true
        @hex_calls = 0
        @rand_calls = 0
        Phlex::HTML.new.call(&block)
      ensure
        @active = false
      end

      # `SecureRandom.hex` and `rand` are the only two sources of
      # non-determinism in the 1.6 surface: TooltipContent, SelectContent and
      # DatePicker mint DOM ids with `SecureRandom.hex(4)`, and
      # SidebarMenuSkeleton picks a width with `rand(50..89)`.
      #
      # A snapshot cannot hold a fresh random value. Scrubbing the generated
      # ids with a regexp afterwards would also erase the id -> `for` /
      # `aria-*` / Stimulus-outlet references that are themselves part of
      # parity, so instead both sources are replaced — only while a scenario is
      # rendering — by counters that restart on every scenario. The values are
      # fixed and the cross-references still line up.
      def next_hex(bytes)
        (@hex_calls += 1).to_s(16).rjust(bytes * 2, "0")
      end

      # Only `rand(Range)` is pinned, because that is the only shape 1.6 uses.
      # Any other shape raises rather than quietly returning a number the
      # snapshot cannot reproduce.
      def next_rand(argument)
        unless argument.is_a?(Range)
          raise ArgumentError, "the golden suite only pins rand(Range); got rand(#{argument.inspect}). " \
            "Pin the new shape in test/golden/harness.rb before recording a snapshot that depends on it."
        end

        values = argument.to_a
        if values.size > MAX_PINNED_RANGE
          raise ArgumentError, "refusing to pin rand(#{argument.inspect}): #{values.size} values exceeds MAX_PINNED_RANGE."
        end

        values.fetch((@rand_calls += 1) % values.size)
      end

      # Coverage bookkeeping. Recording on instantiation rather than on render
      # is deliberate: it is the cheapest hook that sees every class, and a
      # component instantiated inside a scenario is a component the scenario
      # reaches.
      def classes_rendered
        @classes_rendered ||= {}
      end

      def record(klass)
        classes_rendered[klass.name] = true if active?
      end
    end
  end

  module DeterministicSecureRandom
    def hex(bytes = 16)
      Golden::Harness.active? ? Golden::Harness.next_hex(bytes) : super
    end
  end

  module DeterministicRandom
    private

    def rand(argument = nil)
      Golden::Harness.active? ? Golden::Harness.next_rand(argument) : super
    end
  end

  module RecordsRenderedClass
    def initialize(...)
      Golden::Harness.record(self.class)
      super
    end
  end
end

SecureRandom.singleton_class.prepend(Golden::DeterministicSecureRandom)

# Both patches are scoped to RubyUI::Base rather than to Kernel/Object, so
# nothing outside a component render is affected — including Minitest's own
# seeding.
RubyUI::Base.prepend(Golden::DeterministicRandom)
RubyUI::Base.prepend(Golden::RecordsRenderedClass)
