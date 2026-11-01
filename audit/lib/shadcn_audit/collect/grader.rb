module ShadcnAudit
  module Collect
    # Grades the objective Look lines from what the driver observed on both
    # sides. Pure: same observations in any order give the same lines.
    class Grader
      LOOK_SOURCE = "computed styles (shadcn-audit collect)"
      STATE_ORDER = %w[closed open focus after-esc].freeze
      THEME_ORDER = %w[light dark].freeze
      FONT_PROPS = %w[font-family font-size font-weight line-height letter-spacing width height].freeze

      def initialize(folder:, parts:, divergences:, theme_diffs:, environment_diff_keys:)
        @folder = folder
        @parts = parts
        @divergences = divergences
        @theme_diffs = theme_diffs
        @environment_diff_keys = environment_diff_keys
      end

      def lines(observations)
        observations = observations.sort_by { |o| [THEME_ORDER.index(o["theme"]) || 9, STATE_ORDER.index(o["state"]) || 9, o["state"]] }
        look_lines(observations.select { |o| o["rubyui"]["reached"] && o["shadcn"]["reached"] })
      end

      private

      def look_lines(observations)
        matching = []
        lines = @parts.flat_map do |part|
          part_lines = look_part(part, observations)
          matching << part if part_lines.empty?
          part_lines
        end
        return lines if matching.empty?

        lines << line("Look", "pass", "#{matching.join(", ")}: computed styles match", "same", LOOK_SOURCE)
      end

      def look_part(part, observations)
        buckets = Hash.new { |h, k| h[k] = [] }
        mismatches = []
        observations.each do |o|
          at = "#{o["state"]}/#{o["theme"]}"
          r = Array(o["rubyui"]["parts"][part])
          s = Array(o["shadcn"]["parts"][part])
          next mismatches << "#{r.size}/#{s.size} visible elements in #{at}" if r.size != s.size

          r.zip(s).each do |re, se|
            (re["styles"].keys | se["styles"].keys).sort.each do |prop|
              rv = re["styles"][prop].to_s
              sv = se["styles"][prop].to_s
              next if Normalize.value(rv) == Normalize.value(sv)

              buckets[classify(part, prop, rv, sv, o["theme"])] << {prop: prop, rubyui: rv, shadcn: sv, at: at}
            end
          end
        end
        part_lines(part, buckets, mismatches)
      end

      def classify(part, prop, rv, sv, theme)
        token = theme_token(rv, sv, theme)
        return [:theme, token] if token
        return [:environment, "font"] if @environment_diff_keys.include?("font") && FONT_PROPS.include?(prop)

        entry = @divergences.match(component: @folder, dimension: "Look", part: part, key: prop, rubyui: rv, shadcn: sv)
        entry ? [:intentional, entry["reason"]] : [:diff, nil]
      end

      def theme_token(rv, sv, theme)
        @theme_diffs.find do |d|
          d["mode"] == theme && Normalize.value(d["rubyui"]) == Normalize.value(rv) && Normalize.value(d["shadcn"]) == Normalize.value(sv)
        end&.fetch("token")
      end

      def part_lines(part, buckets, mismatches)
        lines = []
        unless mismatches.empty?
          lines << line("Look", "inconclusive", "", "", "", "#{part}: selector matched #{mismatches.join("; ")}")
        end
        diffs = buckets.select { |(kind, _), _| kind == :diff }.values.flatten
        lines << values_line(part, "fail", diffs) unless diffs.empty?
        buckets.select { |(kind, _), _| kind == :intentional }.sort.each do |(_, reason), found|
          lines << values_line(part, "pass", found, basis: "intentional", source: "audit/divergences.yml", note: reason)
        end
        explained = buckets.select { |(kind, _), _| %i[theme environment].include?(kind) }
        unless explained.empty?
          causes = explained.keys.sort.map { |kind, what| (kind == :theme) ? "theme token #{what}" : "environment diff: #{what}" }.uniq
          lines << values_line(part, "inconclusive", explained.values.flatten, source: "", note: "explained by #{causes.join(", ")}")
        end
        lines
      end

      def values_line(part, status, found, basis: nil, source: LOOK_SOURCE, note: nil)
        side = ->(key) { found.map { |f| "#{f[:prop]}: #{f[key]}" }.uniq.sort.join("; ") }
        at = found.map { |f| f[:at] }.uniq
        line("Look", status, side.call(:rubyui), side.call(:shadcn), source, note || "#{part} — #{at.join(", ")}", basis: basis)
      end

      def line(dimension, status, rubyui, shadcn, source, note = "", basis: nil)
        {"dimension" => dimension, "status" => status, "basis" => basis, "rubyui" => rubyui,
         "shadcn" => shadcn, "source" => source, "note" => note}
      end
    end
  end
end
