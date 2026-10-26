require "erb"
require "shadcn_audit/renderers/terminal"

module ShadcnAudit
  module Renderers
    # Side-by-side screenshot page (design §B). Screenshot paths stay as
    # written in the report: relative to the run folder (`out_dir`).
    module Html
      TEMPLATE = File.expand_path("report.html.erb", __dir__)
      LOOKISH = %w[Look Behavior Animation].freeze

      # Returns the written path, or nil when no component qualifies.
      def self.render(report, out_dir:)
        components = report.components.select { |c| qualifies?(c) }
        return nil if components.empty?

        FileUtils.mkdir_p(out_dir)
        path = File.join(out_dir.to_s, "report.html")
        File.write(path, ERB.new(File.read(TEMPLATE), trim_mode: "-").result_with_hash(
          report: report, components: components, t: Terminal, h: ERB::Util.method(:h)
        ))
        path
      end

      def self.qualifies?(component)
        Array(component["screenshots"]).any? &&
          component["lines"].any? { |l| LOOKISH.include?(l["dimension"]) && l["status"] != "pass" }
      end
    end
  end
end
