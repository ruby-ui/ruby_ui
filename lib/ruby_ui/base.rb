# frozen_string_literal: true

require "tailwind_merge"

module RubyUI
  # Phlex base class for generated --engine=phlex components.
  # Uses the same class-merging semantics as ComponentBase so generated
  # Phlex classes work identically to the plain Ruby source.
  class Base < Phlex::HTML
    TAILWIND_MERGER = ::TailwindMerge::Merger.new.freeze unless defined?(TAILWIND_MERGER)

    attr_reader :attrs

    def initialize(**user_attrs)
      user_class = user_attrs.delete(:class)
      raw_defaults = default_attrs
      default_class = raw_defaults[:class]
      defaults = raw_defaults.except(:class)

      @attrs = deep_merge_attrs(defaults, user_attrs)

      all_classes = [default_class, user_class].flatten.compact
      @attrs[:class] = TAILWIND_MERGER.merge(all_classes) if all_classes.any?
    end

    private

    def default_attrs
      {}
    end

    def deep_merge_attrs(base, overrides)
      base.merge(overrides) do |_key, old_val, new_val|
        (old_val.is_a?(Hash) && new_val.is_a?(Hash)) ? deep_merge_attrs(old_val, new_val) : new_val
      end
    end
  end
end
