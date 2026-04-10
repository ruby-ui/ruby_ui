# frozen_string_literal: true

require "tailwind_merge"

module RubyUI
  # Shared base module for all plain Ruby component classes.
  # Provides TailwindMerge class merging and deep attribute merging.
  # Components include this module and override +default_attrs+ to declare
  # their base HTML attributes and Tailwind classes.
  #
  # Usage:
  #   class MyComponent
  #     include RubyUI::ComponentBase
  #
  #     private
  #
  #     def default_attrs
  #       { class: "base-class", data: { controller: "my-ctrl" } }
  #     end
  #   end
  module ComponentBase
    TAILWIND_MERGER = ::TailwindMerge::Merger.new.freeze

    # Subclasses with custom params should set all instance variables
    # before calling +super(**attrs)+.
    def initialize(**attrs)
      user_class = attrs.delete(:class)
      raw_defaults = default_attrs
      default_class = raw_defaults[:class]
      defaults = raw_defaults.except(:class)

      @attrs = deep_merge(defaults, attrs)

      all_classes = [default_class, user_class].flatten.compact
      @attrs[:class] = TAILWIND_MERGER.merge(all_classes) if all_classes.any?
    end

    def attrs
      @attrs ||= {}
    end

    private

    def default_attrs
      {}
    end

    def deep_merge(base, overrides)
      base.merge(overrides) do |_key, old_val, new_val|
        (old_val.is_a?(Hash) && new_val.is_a?(Hash)) ? deep_merge(old_val, new_val) : new_val
      end
    end
  end
end
