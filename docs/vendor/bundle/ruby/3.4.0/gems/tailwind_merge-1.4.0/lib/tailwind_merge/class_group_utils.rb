# frozen_string_literal: true

module TailwindMerge
  class ClassGroupUtils
    attr_reader :class_map

    CLASS_PART_SEPARATOR = "-"

    ARBITRARY_PROPERTY_REGEX = /^\[(.+)\]$/

    def initialize(config)
      @config = config
      @class_map = create_class_map(config)
    end

    def class_group_id(class_name)
      class_parts = class_name.split(CLASS_PART_SEPARATOR)

      # Classes like `-inset-1` produce an empty string as first class_part.
      # Assume that classes for negative values are used correctly and remove it from class_parts.
      class_parts.shift if class_parts.first == "" && class_parts.length != 1

      get_group_recursive(class_parts, @class_map) || get_group_id_for_arbitrary_property(class_name)
    end

    def get_group_recursive(class_parts, class_part_object)
      return class_part_object[:class_group_id] if class_parts.empty?

      current_class_part = class_parts.first

      next_class_part_object = class_part_object[:next_part][current_class_part]

      if next_class_part_object
        class_group_from_next_class_part = get_group_recursive(class_parts.drop(1), next_class_part_object)
        return class_group_from_next_class_part if class_group_from_next_class_part
      end

      return if class_part_object[:validators].empty?

      class_rest = class_parts.join(CLASS_PART_SEPARATOR)

      result = class_part_object[:validators].find do |v|
        validator = v[:validator]
        from_theme?(validator) ? validator.call(@config) : validator.call(class_rest)
      end

      result&.fetch(:class_group_id, nil)
    end

    def get_conflicting_class_group_ids(class_group_id, has_postfix_modifier)
      conflicts = @config[:conflicting_class_groups][class_group_id] || []

      if has_postfix_modifier && @config[:conflicting_class_group_modifiers][class_group_id]
        return [*conflicts, *@config[:conflicting_class_group_modifiers][class_group_id]]
      end

      conflicts
    end

    private def create_class_map(config)
      theme = config[:theme]
      class_groups = config[:class_groups]
      class_map = {
        next_part: {},
        validators: [],
      }

      class_groups.each do |(class_group_id, class_group)|
        process_classes_recursively(class_group, class_map, class_group_id, theme)
      end

      class_map
    end

    private def process_classes_recursively(class_group, class_part_object, class_group_id, theme)
      class_group.each do |class_definition|
        if class_definition.is_a?(String)
          class_part_object_to_edit = class_definition.empty? ? class_part_object : get_class_part(class_part_object, class_definition)
          class_part_object_to_edit[:class_group_id] = class_group_id
        elsif class_definition.is_a?(Proc)
          if from_theme?(class_definition)
            process_classes_recursively(class_definition.call(@config), class_part_object, class_group_id, theme)
          else
            class_part_object[:validators] << {
              validator: class_definition,
              class_group_id: class_group_id,
            }
          end
        else
          class_definition.each do |key, nested_class_group|
            process_classes_recursively(
              nested_class_group,
              get_class_part(class_part_object, key),
              class_group_id,
              theme,
            )
          end
        end
      end
    end

    private def get_class_part(class_part_object, path)
      current_class_part_object = class_part_object

      path.to_s.split(CLASS_PART_SEPARATOR).each do |path_part|
        unless current_class_part_object[:next_part].key?(path_part)
          current_class_part_object[:next_part][path_part] = {
            next_part: {},
            validators: [],
          }
        end

        current_class_part_object = current_class_part_object[:next_part][path_part]
      end

      current_class_part_object
    end

    private def get_group_id_for_arbitrary_property(class_name)
      match = ARBITRARY_PROPERTY_REGEX.match(class_name)
      return unless match

      property = match[1].to_s.split(":", 2).first

      # Use two dots here because one dot is used as prefix for class groups in plugins
      "arbitrary..#{property}" if property && !property.empty?
    end

    private def from_theme?(validator)
      TailwindMerge::Config::VALID_THEME_IDS.include?(validator.object_id)
    end
  end
end
