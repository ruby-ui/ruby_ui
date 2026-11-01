module ShadcnAudit
  module Collect
    # Canonical form for computed values so formatting noise isn't a diff.
    module Normalize
      DECIMAL = /-?\d+\.\d+/

      def self.value(value)
        value.to_s.strip.downcase.gsub(/\s+/, " ")
          .gsub(DECIMAL) { |n| format("%.2f", n.to_f).sub(/\.?0+\z/, "") }
      end
    end
  end
end
