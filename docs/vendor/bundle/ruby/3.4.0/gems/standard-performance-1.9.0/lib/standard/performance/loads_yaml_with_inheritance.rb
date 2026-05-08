require "yaml"

module Standard
  module Performance
    class LoadsYamlWithInheritance
      def load(path)
        yaml = YAML.load_file(path)
        if (parent_path = yaml.delete("inherit_from"))
          base_path = File.dirname(path)
          parent_yaml = load(File.join(base_path, parent_path))

          two_layer_merge(parent_yaml, yaml)
        else
          yaml
        end
      end

      private

      def two_layer_merge(parent, base)
        parent.merge(base) do |key, parent_value, base_value|
          if parent_value.is_a?(Hash) && base_value.is_a?(Hash)
            parent_value.merge(base_value)
          else
            base_value
          end
        end
      end
    end
  end
end
