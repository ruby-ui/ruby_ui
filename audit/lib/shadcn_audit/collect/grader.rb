module ShadcnAudit
  module Collect
    # Grades the objective Look and ARIA lines from what the driver observed
    # on both sides. Pure: same observations in any order give the same lines.
    class Grader
      LOOK_SOURCE = "computed styles (shadcn-audit collect)"
      ARIA_SOURCE = "accessibility tree (shadcn-audit collect)"
      ARIA_ATTRS = %w[aria-expanded aria-controls aria-haspopup aria-describedby].freeze
      STATE_ORDER = %w[closed open focus after-esc].freeze
      THEME_ORDER = %w[light dark].freeze
      FONT_PROPS = %w[font-family font-size font-weight line-height letter-spacing width height].freeze
      SNAPSHOT_LIMIT = 200

      DIMENSIONS = {
        "Look" => {diff: "fail", source: LOOK_SOURCE, match_text: "computed styles match"},
        "ARIA" => {diff: "warn", source: ARIA_SOURCE, match_text: "accessibility tree matches"}
      }.freeze

      def initialize(folder:, parts:, divergences:, theme_diffs:, environment_diff_keys:)
        @folder = folder
        @parts = parts
        @divergences = divergences
        @theme_diffs = theme_diffs
        @environment_diff_keys = environment_diff_keys
      end

      def lines(observations)
        observations = observations.sort_by { |o| [THEME_ORDER.index(o["theme"]) || 9, STATE_ORDER.index(o["state"]) || 9, o["state"]] }
        reached = observations.select { |o| o["rubyui"]["reached"] && o["shadcn"]["reached"] }
        unreached = unreached_notes(observations)
        DIMENSIONS.keys.flat_map do |dimension|
          unreached.map { |note| line(dimension, "inconclusive", "", "", "", note) } +
            dimension_lines(dimension, reached)
        end
      end

      private

      def unreached_notes(observations)
        groups = Hash.new { |h, k| h[k] = [] }
        observations.each do |o|
          %w[rubyui shadcn].each do |side|
            next if o[side]["reached"]
            groups[[side, o[side]["reason"].to_s]] << "#{o["state"]}/#{o["theme"]}"
          end
        end
        groups.map { |(side, reason), at| "#{at.join(", ")} not reached on #{side}: #{reason}" }
      end

      def dimension_lines(dimension, observations)
        return [] if observations.empty?

        matching = []
        environment = {}
        lines = @parts.flat_map do |part|
          part_lines, env_keys = compare_part(dimension, part, observations)
          environment[part] = env_keys unless env_keys.empty?
          matching << part if part_lines.empty? && env_keys.empty?
          part_lines
        end
        lines << environment_line(dimension, environment) unless environment.empty?
        return lines if matching.empty?

        config = DIMENSIONS[dimension]
        lines << line(dimension, "pass", "#{matching.join(", ")}: #{config[:match_text]}", "same", config[:source])
      end

      # One line for every difference the environment explains, whatever the
      # part: the cause is shared and already in environment_diffs.
      def environment_line(dimension, environment)
        keys = environment.values.flatten.uniq.sort
        line(dimension, "inconclusive", "properties: #{keys.join(", ")}", "", "",
          "#{environment.keys.join(", ")} — explained by environment diff: font")
      end

      def compare_part(dimension, part, observations)
        buckets = Hash.new { |h, k| h[k] = [] }
        mismatches = []
        observations.each do |o|
          at = "#{o["state"]}/#{o["theme"]}"
          r = Array(o["rubyui"]["parts"][part])
          s = Array(o["shadcn"]["parts"][part])
          next mismatches << "#{r.size}/#{s.size} visible elements in #{at}" if r.size != s.size

          r.zip(s).each do |re, se|
            rf = facts(dimension, re)
            sf = facts(dimension, se)
            (rf.keys | sf.keys).sort.each do |key|
              rv = rf[key].to_s
              sv = sf[key].to_s
              next if Normalize.value(rv) == Normalize.value(sv)

              shown = (key == "snapshot") ? snapshot_delta(rv, sv) : [rv, sv]
              buckets[classify(dimension, part, key, rv, sv, o["theme"])] << {key: key, rubyui: shown[0], shadcn: shown[1], at: at}
            end
          end
        end
        env_keys = buckets.select { |(kind, _), _| kind == :environment }.values.flatten.map { |f| f[:key] }.uniq
        [part_lines(dimension, part, buckets.reject { |(kind, _), _| kind == :environment }, mismatches), env_keys]
      end

      def facts(dimension, element)
        return element["styles"] || {} if dimension == "Look"

        attrs = element["attrs"] || {}
        {"snapshot" => element["aria"]}.merge(ARIA_ATTRS.to_h { |name| [name, attrs[name]] })
      end

      def classify(dimension, part, key, rv, sv, theme)
        if dimension == "Look"
          token = theme_token(rv, sv, theme)
          return [:theme, token] if token
          return [:environment, "font"] if @environment_diff_keys.include?("font") && FONT_PROPS.include?(key)
        end

        entry = @divergences.match(component: @folder, dimension: dimension, part: part, key: key, rubyui: rv, shadcn: sv)
        entry ? [:intentional, entry["reason"]] : [:diff, nil]
      end

      def theme_token(rv, sv, theme)
        @theme_diffs.find do |d|
          d["mode"] == theme && Normalize.value(d["rubyui"]) == Normalize.value(rv) && Normalize.value(d["shadcn"]) == Normalize.value(sv)
        end&.fetch("token")
      end

      def part_lines(dimension, part, buckets, mismatches)
        config = DIMENSIONS[dimension]
        lines = []
        unless mismatches.empty?
          lines << line(dimension, "inconclusive", "", "", "", "#{part}: selector matched #{mismatches.join("; ")}")
        end
        diffs = buckets.select { |(kind, _), _| kind == :diff }.values.flatten
        lines << values_line(dimension, part, config[:diff], diffs, source: config[:source]) unless diffs.empty?
        buckets.select { |(kind, _), _| kind == :intentional }.sort.each do |(_, reason), found|
          lines << values_line(dimension, part, "pass", found, basis: "intentional", source: "audit/divergences.yml", note: reason)
        end
        explained = buckets.select { |(kind, _), _| kind == :theme }
        unless explained.empty?
          tokens = explained.keys.map(&:last).uniq.sort
          lines << values_line(dimension, part, "inconclusive", explained.values.flatten, source: "", note: "explained by theme token #{tokens.join(", ")}")
        end
        lines
      end

      def values_line(dimension, part, status, found, source:, basis: nil, note: nil)
        side = ->(which) { found.map { |f| "#{f[:key]}: #{display(f[which])}" }.uniq.sort.join("; ") }
        at = found.map { |f| f[:at] }.uniq
        line(dimension, status, side.call(:rubyui), side.call(:shadcn), source, "#{part} — #{note || at.join(", ")}", basis: basis)
      end

      # Snapshot lines found on one side only, so the difference is visible
      # instead of buried in a truncated tree.
      def snapshot_delta(rv, sv)
        r = rv.lines.map(&:strip).reject(&:empty?)
        s = sv.lines.map(&:strip).reject(&:empty?)
        [only_here(r, s), only_here(s, r)]
      end

      def only_here(lines, other)
        extra = lines - other
        return "only here: #{extra.join(" | ")}" unless extra.empty?

        lines.empty? ? "" : "same lines, different order"
      end

      def display(value)
        return "(none)" if value.empty?
        (value.length > SNAPSHOT_LIMIT) ? "#{value[0, SNAPSHOT_LIMIT]}…" : value
      end

      def line(dimension, status, rubyui, shadcn, source, note = "", basis: nil)
        {"dimension" => dimension, "status" => status, "basis" => basis, "rubyui" => rubyui,
         "shadcn" => shadcn, "source" => source, "note" => note}
      end
    end
  end
end
