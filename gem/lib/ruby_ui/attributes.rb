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
  # Time use iso8601 at the top level — nested under a Hash they raise, as
  # Phlex has no case for them there; a Hash nests as `name-key`, with `_:`
  # naming the parent itself; Array/Set values are space-joined tokens of
  # String/Symbol/Integer/Float (nil skipped, nested arrays flattened, empty
  # result omits the attribute, anything else — `true`, a Date, … — raises, as
  # Phlex has no case for it in a token list either); `style:` — the Symbol key
  # only, a String `"style"` key nests like any other Hash key — Hash becomes
  # "prop: value; prop: value;" (a non-String/Symbol/Integer/Float value
  # raises) and `style:` Array "a; b;".
  #
  # Phlex's guards (phlex/sgml/attributes.rb) are ported, so a component given
  # untrusted values keeps the protection it has today: a name with `<>&"'/=`,
  # whitespace or NUL raises; `srcdoc`, `sandbox`, `http-equiv` and any `on*`
  # handler name raise; a URL-bearing attribute (`href`, `src`, `action`, …)
  # whose serialized value, character references decoded, starts with
  # `javascript:` is dropped — serialized first, as Phlex does, so `href: 1`
  # renders and `href: :"javascript:x"` does not. Not ported: Phlex's
  # `:id`-must-be-a-lowercase-Symbol check (a Phlex convention), the leading
  # space it leaves when the first `style:` value is nil (no snapshot depends
  # on it), and an object that only responds to `to_h` — Phlex nests it, `flat`
  # refuses it (fail-loud, deliberate).
  module Attributes
    TAILWIND_MERGER = TailwindMerge::Merger.new.freeze

    UNSAFE_ATTRIBUTES = Set.new(%w[srcdoc sandbox http-equiv]).freeze
    REF_ATTRIBUTES = Set.new(%w[href src action formaction lowsrc dynsrc background ping xlinkhref]).freeze
    UNSAFE_ATTRIBUTE_NAME_CHARS = %r{[<>&"'/=\s\x00]}

    # The named character references Phlex decodes before the `javascript:`
    # check — exactly these three; every other named reference decodes to
    # nothing, as in Phlex. Numeric references are decoded in full.
    NAMED_REFERENCES = {"colon" => ":", "tab" => "\t", "newline" => "\n"}.freeze

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
            # Phlex keys this on the Symbol `:style` itself, not on the
            # dasherized name: a String `"style"` key nests like any other
            # Hash key (`style-width="1px"`) rather than being read as CSS.
            if key == :style
              emit(out, name, styles(value))
            else
              refuse_url_value!(name, value)
              nested(value, "#{name}-", out)
            end
          when Array, Set
            serialized = (key == :style) ? styles(value) : tokens(value)
            refuse_url_value!(name, value) if serialized.nil?
            emit(out, name, serialized)
          else
            emit(out, name, scalar(value))
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

      # Phlex serializes first and guards the serialized value, so `href: 1`
      # renders `href="1"` and `href: :"javascript:x"` is dropped. A nil here
      # is an empty token list, which omits the attribute.
      def emit(out, name, serialized)
        return if serialized.nil?

        out[name] = serialized unless guard(name, serialized) == :drop
      end

      # Phlex raises for a URL attribute whose value has no String form — an
      # empty token list or a Hash — rather than omitting it.
      def refuse_url_value!(name, value)
        return unless REF_ATTRIBUTES.include?(name.downcase.delete("^a-z-"))

        raise ArgumentError, "invalid value for #{name}: #{value.inspect}"
      end

      # :keep or :drop. Raises for the names Phlex refuses.
      def guard(name, serialized)
        raise ArgumentError, "unsafe attribute name #{name.inspect}" if name.match?(UNSAFE_ATTRIBUTE_NAME_CHARS)

        normalized = name.downcase.delete("^a-z-")
        if UNSAFE_ATTRIBUTES.include?(normalized) ||
            (normalized.bytesize > 2 && normalized.start_with?("on") && !normalized.include?("-"))
          raise ArgumentError, "unsafe attribute name #{name.inspect}"
        end

        return :keep unless REF_ATTRIBUTES.include?(normalized)

        decode_references(serialized).downcase.delete("^a-z:").start_with?("javascript:") ? :drop : :keep
      end

      def decode_references(value)
        value
          .gsub(/&#x([0-9a-f]+);?/i) { codepoint($1.to_i(16)) }
          .gsub(/&#(\d+);?/) { codepoint($1.to_i) }
          .gsub(/&([a-z][a-z0-9]+);?/i) { NAMED_REFERENCES[$1.downcase] || "" }
      end

      # Phlex swallows a reference it cannot pack; so does this.
      def codepoint(number)
        [number].pack("U*")
      rescue RangeError
        ""
      end

      def nested(hash, prefix, out)
        hash.each do |key, value|
          next unless value

          name = (key == :_) ? prefix.delete_suffix("-") : "#{prefix}#{key_name(key)}"
          raise ArgumentError, "unsafe attribute name #{name.inspect}" if name.match?(UNSAFE_ATTRIBUTE_NAME_CHARS)

          case value
          when Hash then nested(value, "#{name}-", out)
          when Array, Set then (joined = tokens(value)) && out[name] = joined
          # Phlex's nested-attributes case has no branch for Date/Time (only
          # the top-level case does), so nesting one raises here too.
          when Date, Time then raise ArgumentError, "invalid attribute value #{value.inspect}"
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
          when String, Symbol, Integer, Float then scalar(token)
          else raise ArgumentError, "invalid token type #{token.class}"
          end
        end
        list.join(" ") unless list.empty?
      end

      def styles(value)
        case value
        when Hash
          value.filter_map do |property, v|
            case v
            when nil then nil
            when String, Symbol, Integer, Float then "#{key_name(property)}: #{scalar(v)};"
            else raise ArgumentError, "invalid style value #{v.inspect}"
            end
          end.join(" ")
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
