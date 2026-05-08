# frozen_string_literal: true

module TailwindMerge
  class TailwindClass < Struct.new(:is_external, :modifiers, :has_important_modifier, :base_class_name, :maybe_postfix_modifier_position)
  end

  module ParseClassName
    IMPORTANT_MODIFIER = "!"
    MODIFIER_SEPARATOR = ":"
    MODIFIER_SEPARATOR_LENGTH = MODIFIER_SEPARATOR.length

    ##
    # Parse class name into parts.
    #
    # Inspired by `splitAtTopLevelOnly` used in Tailwind CSS
    # @see https://github.com/tailwindlabs/tailwindcss/blob/v3.2.2/src/util/splitAtTopLevelOnly.js
    def parse_class_name(class_name, prefix: nil)
      unless prefix.nil?
        full_prefix = "#{prefix}#{MODIFIER_SEPARATOR}"
        if class_name.start_with?(full_prefix)
          return parse_class_name(class_name[full_prefix.length..])
        else
          return TailwindClass.new(
            is_external: true,
            modifiers: [],
            has_important_modifier: false,
            base_class_name: class_name,
            maybe_postfix_modifier_position: nil,
          )
        end
      end

      modifiers = []

      bracket_depth = 0
      paren_depth = 0
      modifier_start = 0
      postfix_modifier_position = nil

      class_name.each_char.with_index do |char, index|
        if bracket_depth.zero? && paren_depth.zero?
          if char == MODIFIER_SEPARATOR
            modifiers << class_name[modifier_start...index]
            modifier_start = index + MODIFIER_SEPARATOR_LENGTH
            next
          elsif char == "/"
            postfix_modifier_position = index
            next
          end
        end

        bracket_depth += 1 if char == "["
        bracket_depth -= 1 if char == "]"
        paren_depth += 1 if char == "("
        paren_depth -= 1 if char == ")"
      end

      base_class_name_with_important_modifier = modifiers.empty? ? class_name : class_name[modifier_start..]

      base_class_name, has_important_modifier = strip_important_modifier(base_class_name_with_important_modifier)

      maybe_postfix_modifier_position = if postfix_modifier_position && postfix_modifier_position > modifier_start
        postfix_modifier_position - modifier_start
      end

      TailwindClass.new(
        is_external: false,
        modifiers:,
        has_important_modifier:,
        base_class_name: base_class_name,
        maybe_postfix_modifier_position:,
      )
    end

    def strip_important_modifier(base_class_name)
      if base_class_name.end_with?(IMPORTANT_MODIFIER)
        return [base_class_name[0...-IMPORTANT_MODIFIER.length], true]
      end

      # In Tailwind CSS v3 the important modifier was at the start of the base class name. This is still supported for legacy reasons.
      # @see https://github.com/dcastil/tailwind-merge/issues/513#issuecomment-2614029864
      if base_class_name.start_with?(IMPORTANT_MODIFIER)
        return [base_class_name[1..], true]
      end

      [base_class_name, false]
    end
  end
end
