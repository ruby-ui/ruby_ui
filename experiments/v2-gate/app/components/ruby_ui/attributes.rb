# frozen_string_literal: true

require "tailwind_merge"

module RubyUI
  # Attribute handling for the 2.0 layer, with Phlex 2.4.1 semantics. Pure Ruby,
  # no view context, so `RubyUI::X.new(...).attrs` works anywhere.
  #
  #   mix(*hashes)         Phlex::Helpers#mix — caller attributes over defaults.
  #   merge_classes(value) TailwindMerge over the mixed `class`, as 1.6 Base does.
  #   flat(hash)           The nested hash serialized into the flat, string-keyed
  #                        hash `tag.attributes` expects. Rails then only quotes
  #                        and escapes.
  #
  # Rules reproduced from phlex-2.4.1/lib/phlex/sgml/attributes.rb: Symbol keys
  # are dasherized at every level; nil and false omit the attribute; true is a
  # bare attribute (here "" — Rails renders `disabled="disabled"` for boolean
  # attributes and `aria-x=""` for the rest, which canonicalize like Phlex's
  # bare form); Symbol values are dasherized; Integer/Float use to_s; Date and
  # Time use iso8601; a Hash nests as `name-key`, with `_:` naming the parent
  # itself; Array/Set values are space-joined tokens (nil skipped, nested arrays
  # flattened, empty result omits the attribute); `style:` Hash becomes
  # "prop: value; prop: value;" and `style:` Array "a; b;".
  #
  # Not reproduced: Phlex's guards (unsafe attribute names, `javascript:` refs,
  # the `:id` key check) and the leading space Phlex leaves when the first style
  # value is nil. None of the 1.6 snapshots depend on either.
  module Attributes
    TAILWIND_MERGER = TailwindMerge::Merger.new.freeze

    class << self
      # Same semantics as Phlex::Helpers#mix (phlex-2.4.1/lib/phlex/helpers.rb).
      def mix(*args)
        args.each_with_object({}) do |object, result|
          result.merge!(object) do |_key, old, new|
            case [old, new].freeze
            in [Array, Array] | [Set, Set] then old + new
            in [Array, Set] then old + new.to_a
            in [Array, String] then old + [new]
            in [Hash, Hash] then mix(old, new)
            in [Set, Array] then old.to_a + new
            in [Set, String] then old.to_a + [new]
            in [String, Array] then [old] + new
            in [String, Set] then [old] + new.to_a
            in [String, String] then "#{old} #{new}"
            in [_, Hash] then {_: old, **new}
            in [Hash, _] then {**old, _: new}
            in [_, nil] then old
            else new
            end
          end

          result.transform_keys! do |key|
            key.end_with?("!") ? key.name.chop.to_sym : key
          end
        end
      end

      # 1.6: `@attrs[:class] = TAILWIND_MERGER.merge(@attrs[:class])`. Accepts
      # the String or (nested) Array that mix produces.
      def merge_classes(value)
        TAILWIND_MERGER.merge(value)
      end

      def flat(attributes)
        attributes.each_with_object({}) do |(key, value), out|
          next unless value

          name = key_name(key)
          case value
          when Hash
            (name == "style") ? out[name] = styles(value) : nested(value, "#{name}-", out)
          when Array, Set
            if name == "style"
              out[name] = styles(value)
            elsif (joined = tokens(value))
              out[name] = joined
            end
          else
            out[name] = scalar(value)
          end
        end
      end

      private

      def key_name(key)
        case key
        when String then key
        when Symbol then key.name.tr("_", "-")
        else raise ArgumentError, "attribute keys must be Strings or Symbols, got #{key.inspect}"
        end
      end

      def nested(hash, prefix, out)
        hash.each do |key, value|
          next unless value

          name = (key == :_) ? prefix.delete_suffix("-") : "#{prefix}#{key_name(key)}"
          case value
          when Hash then nested(value, "#{name}-", out)
          when Array, Set then (joined = tokens(value)) && out[name] = joined
          else out[name] = scalar(value)
          end
        end
      end

      def scalar(value)
        case value
        when true then ""
        when String then value
        when Symbol then value.name.tr("_", "-")
        when Integer, Float then value.to_s
        when Date, Time then value.iso8601
        else raise ArgumentError, "invalid attribute value #{value.inspect}"
        end
      end

      def tokens(values)
        list = values.filter_map do |token|
          case token
          when nil then nil
          when Array, Set then tokens(token)
          else scalar(token)
          end
        end
        list.join(" ") unless list.empty?
      end

      def styles(value)
        case value
        when Hash
          value.filter_map { |property, v| "#{key_name(property)}: #{scalar(v)};" unless v.nil? }.join(" ")
        else
          value.filter_map do |style|
            case style
            when nil then nil
            when Hash then styles(style)
            when String then (style.empty? || style.end_with?(";")) ? style : "#{style};"
            else raise ArgumentError, "invalid style #{style.inspect}"
            end
          end.join(" ")
        end
      end
    end
  end
end
