module ShadcnAudit
  module Drift
    # Compares two Reference#for results (baseline vs head). Classes are
    # compared as sets: shadcn reordering a class list is not drift.
    module Diff
      def self.compare(before, after)
        before_parts = before.fetch("parts", {})
        after_parts = after.fetch("parts", {})
        shared = before_parts.keys & after_parts.keys
        {
          "parts_added" => (after_parts.keys - before_parts.keys).sort,
          "parts_removed" => (before_parts.keys - after_parts.keys).sort,
          "classes" => changes(shared.to_h { |slot| [slot, [effective(before_parts[slot]), effective(after_parts[slot])]] }),
          "variants" => changes(variant_pairs(before.fetch("variants", {}), after.fetch("variants", {}))),
          "warnings_added" => (after.fetch("warnings", []) - before.fetch("warnings", [])).sort
        }
      end

      def self.empty?(diff)
        %w[parts_added parts_removed classes variants warnings_added].all? { |key| diff[key].empty? }
      end

      # A slot's own classes plus those of its extra elements ("also": the
      # same data-slot rendered again elsewhere in the file).
      def self.effective(part)
        return [] unless part

        (Array(part["effective"]) + Array(part["also"]).flat_map { |extra| Array(extra["effective"]) }).uniq
      end

      # {key => [old_classes, new_classes]} -> only the keys whose sets differ.
      def self.changes(pairs)
        pairs.sort.each_with_object({}) do |(key, (old, new)), out|
          added = (new - old).sort
          removed = (old - new).sort
          out[key] = {"added" => added, "removed" => removed} unless added.empty? && removed.empty?
        end
      end

      # "cva/group/name" => [old_classes, new_classes]
      def self.variant_pairs(before, after)
        flat_before = flatten(before)
        flat_after = flatten(after)
        (flat_before.keys | flat_after.keys).to_h { |path| [path, [flat_before.fetch(path, []), flat_after.fetch(path, [])]] }
      end

      def self.flatten(variants)
        variants.each_with_object({}) do |(cva, groups), out|
          groups.each do |group, names|
            names.each { |name, classes| out["#{cva}/#{group}/#{name}"] = Array(classes) }
          end
        end
      end
    end
  end
end
