# frozen_string_literal: true

require "set"

module TailwindMerge
  module Validators
    class << self
      def arbitrary_value?(class_part, test_label, test_value)
        match = ARBITRARY_VALUE_REGEX.match(class_part)
        return false unless match

        return test_label.call(match[1]) unless match[1].nil?

        test_value.call(match[2])
      end

      def arbitrary_variable?(class_part, test_label, should_match_no_label: false)
        match = ARBITRARY_VARIABLE_REGEX.match(class_part)
        return false unless match

        return test_label.call(match[1]) unless match[1].nil?

        should_match_no_label
      end

      def numeric?(x)
        Float(x, exception: false).is_a?(Numeric)
      end

      def integer?(x)
        Integer(x, exception: false).is_a?(Integer)
      end
    end

    ARBITRARY_VALUE_REGEX = /^\[(?:(\w[\w-]*):)?(.+)\]$/i
    ARBITRARY_VARIABLE_REGEX = /^\((?:(\w[\w-]*):)?(.+)\)$/i
    FRACTION_REGEX = %r{^\d+(?:\.\d+)?/\d+(?:\.\d+)?$}
    TSHIRT_UNIT_REGEX = /^(\d+(\.\d+)?)?(xs|sm|md|lg|xl)$/
    LENGTH_UNIT_REGEX = /\d+(%|px|r?em|[sdl]?v([hwib]|min|max)|pt|pc|in|cm|mm|cap|ch|ex|r?lh|cq(w|h|i|b|min|max))|\b(calc|min|max|clamp)\(.+\)|^0$/
    COLOR_FUNCTION_REGEX = /^(rgba?|hsla?|hwb|(ok)?(lab|lch)|color-mix)\(.+\)$/

    # Shadow always begins with x and y offset separated by underscore optionally prepended by inset
    SHADOW_REGEX = /^(inset_)?-?((\d+)?\.?(\d+)[a-z]+|0)_-?((\d+)?\.?(\d+)[a-z]+|0)/
    IMAGE_REGEX = /^(url|image|image-set|cross-fade|element|(repeating-)?(linear|radial|conic)-gradient)\(.+\)$/

    IS_FRACTION = ->(value) {
      FRACTION_REGEX.match?(value)
    }

    IS_NUMBER = ->(value) {
      numeric?(value)
    }

    IS_INTEGER = ->(value) {
      integer?(value)
    }

    IS_PERCENT = ->(value) {
      value.end_with?("%") && IS_NUMBER.call(value[0..-2])
    }

    IS_TSHIRT_SIZE = ->(value) {
      TSHIRT_UNIT_REGEX.match?(value)
    }

    IS_ANY = ->(_ = nil) { true }

    IS_LENGTH_ONLY = ->(value) {
      # `colorFunctionRegex` check is necessary because color functions can have percentages in them which which would be incorrectly classified as lengths.
      # For example, `hsl(0 0% 0%)` would be classified as a length without this check.
      # I could also use lookbehind assertion in `lengthUnitRegex` but that isn't supported widely enough.
      LENGTH_UNIT_REGEX.match?(value) && !COLOR_FUNCTION_REGEX.match?(value)
    }

    IS_NEVER = ->(_) { false }

    IS_SHADOW = ->(value) {
      SHADOW_REGEX.match?(value)
    }

    IS_IMAGE = ->(value) {
      IMAGE_REGEX.match?(value)
    }

    IS_ANY_NON_ARBITRARY = ->(value) {
      !IS_ARBITRARY_VALUE.call(value) && !IS_ARBITRARY_VARIABLE.call(value)
    }

    IS_ARBITRARY_SIZE = ->(value) {
      arbitrary_value?(value, IS_LABEL_SIZE, IS_NEVER)
    }

    IS_ARBITRARY_VALUE = ->(value) {
      ARBITRARY_VALUE_REGEX.match(value)
    }

    IS_ARBITRARY_LENGTH = ->(value) {
      arbitrary_value?(value, IS_LABEL_LENGTH, IS_LENGTH_ONLY)
    }

    IS_ARBITRARY_NUMBER = ->(value) {
      arbitrary_value?(value, IS_LABEL_NUMBER, IS_NUMBER)
    }

    IS_ARBITRARY_WEIGHT = ->(value) {
      arbitrary_value?(value, IS_LABEL_WEIGHT, IS_ANY)
    }

    IS_ARBITRARY_FAMILY_NAME = ->(value) {
      arbitrary_value?(value, IS_LABEL_FAMILY_NAME, IS_NEVER)
    }

    IS_ARBITRARY_POSITION = ->(value) {
      arbitrary_value?(value, IS_LABEL_POSITION, IS_NEVER)
    }

    IS_ARBITRARY_IMAGE = ->(value) {
      arbitrary_value?(value, IS_LABEL_IMAGE, IS_IMAGE)
    }

    IS_ARBITRARY_SHADOW = ->(value) {
      arbitrary_value?(value, IS_LABEL_SHADOW, IS_SHADOW)
    }

    IS_ARBITRARY_VARIABLE = ->(value) {
      ARBITRARY_VARIABLE_REGEX.match(value)
    }

    IS_ARBITRARY_VARIABLE_LENGTH = ->(value) {
      arbitrary_variable?(value, IS_LABEL_LENGTH)
    }

    IS_ARBITRARY_VARIABLE_FAMILY_NAME = ->(value) {
      arbitrary_variable?(value, IS_LABEL_FAMILY_NAME)
    }

    IS_ARBITRARY_VARIABLE_POSITION = ->(value) {
      arbitrary_variable?(value, IS_LABEL_POSITION)
    }

    IS_ARBITRARY_VARIABLE_SIZE = ->(value) {
      arbitrary_variable?(value, IS_LABEL_SIZE)
    }

    IS_ARBITRARY_VARIABLE_IMAGE = ->(value) {
      arbitrary_variable?(value, IS_LABEL_IMAGE)
    }

    IS_ARBITRARY_VARIABLE_SHADOW = ->(value) {
      arbitrary_variable?(value, IS_LABEL_SHADOW, should_match_no_label: true)
    }

    IS_ARBITRARY_VARIABLE_WEIGHT = ->(value) {
      arbitrary_variable?(value, IS_LABEL_WEIGHT, should_match_no_label: true)
    }

    ############
    # Labels
    ############

    IS_LABEL_POSITION = ->(label) {
      label == "position" || label == "percentage"
    }

    IS_LABEL_IMAGE = ->(label) {
      label == "image" || label == "url"
    }

    IS_LABEL_SIZE = ->(label) {
      label == "length" || label == "size" || label == "bg-size"
    }

    IS_LABEL_LENGTH = ->(label) {
      label == "length"
    }

    IS_LABEL_NUMBER = ->(label) {
      label == "number"
    }

    IS_LABEL_FAMILY_NAME = ->(label) {
      label == "family-name"
    }

    IS_LABEL_WEIGHT = ->(label) {
      label == "number" || label == "weight"
    }

    IS_LABEL_SHADOW = ->(label) {
      label == "shadow"
    }
  end
end
