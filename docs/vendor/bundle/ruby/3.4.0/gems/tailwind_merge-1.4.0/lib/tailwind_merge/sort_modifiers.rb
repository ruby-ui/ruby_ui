# frozen_string_literal: true

module TailwindMerge
  module SortModifiers
    # Sorts modifiers according to following schema:
    # - Predefined modifiers are sorted alphabetically
    # - When an arbitrary variant appears, it must be preserved which modifiers are before and after it
    def sort_modifiers(modifiers, order_sensitive_modifiers)
      return modifiers if modifiers.size <= 1

      sorted_modifiers = []
      unsorted_modifiers = []

      modifiers.each do |modifier|
        is_position_sensitive = modifier.start_with?("[") || order_sensitive_modifiers.include?(modifier)

        if is_position_sensitive
          sorted_modifiers.concat(unsorted_modifiers.sort)
          sorted_modifiers << modifier
          unsorted_modifiers.clear
        else
          unsorted_modifiers << modifier
        end
      end

      sorted_modifiers.concat(unsorted_modifiers.sort)

      sorted_modifiers
    end
  end
end
