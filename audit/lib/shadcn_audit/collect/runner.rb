module ShadcnAudit
  module Collect
    # Runs the driver over every state × theme × side for one component,
    # grades the objective lines and writes <run>/collect.json.
    class Runner
      THEMES = %w[light dark].freeze
      SIDES = %w[rubyui shadcn].freeze
      STATES_BY_KIND = Hash.new(Driver::STATES).merge(
        "form_control" => %w[closed focus], "static" => %w[closed]
      ).freeze
      FONT_KEYS = %w[font fonts].freeze

      def initialize(folder:, run_dir:, preview: nil, root: ShadcnAudit.root, theme: nil,
        driver_factory: Driver.method(:open))
        @folder = folder.to_s
        @run_dir = Pathname.new(run_dir)
        @preview = preview && Pathname.new(preview)
        @root = root
        @theme = theme
        @driver_factory = driver_factory
      end

      def call
        map_source, map, divergences = load_config
        entry = map.entry(@folder)
        selectors = map.selectors(@folder)
        raise ArgumentError, "#{@folder} has no selectors in audit/component_map.yml" if entry.nil? || selectors.empty?

        slots = (entry["parts"] || {}).compact
        compared = slots.keys.select { |part| selectors.key?(part) }
        unselected = slots.keys - compared
        FileUtils.mkdir_p(@run_dir.join("screens"))

        observations, environment = @driver_factory.call(audit_dir: @root.join("audit")) do |driver|
          [observe_all(driver, STATES_BY_KIND[entry["kind"]], selectors.slice(*compared), slots), probe_environment(driver)]
        end
        environment_diffs, diff_keys = environment_diffs(environment)
        grader = Grader.new(folder: @folder, parts: compared, divergences: divergences,
          theme_diffs: theme["diffs"], environment_diff_keys: diff_keys)
        lines = unselected.map { |part| missing_selector_line(part) } + grader.lines(observations)

        result = {
          "folder" => @folder, "map_source" => map_source,
          "viewport" => {"w" => Driver::VIEWPORT[:width], "h" => Driver::VIEWPORT[:height]},
          "environment" => environment, "environment_diffs" => environment_diffs,
          "states" => observations, "pixel_diffs" => pixel_diffs(observations),
          "lines" => lines, "screenshots" => screenshots(observations)
        }
        File.write(@run_dir.join("collect.json"), JSON.pretty_generate(result))
        result
      end

      private

      # The audited head's map wins when it already has selectors for the folder.
      def load_config
        if @preview
          preview_map = ComponentMap.load(@preview.join("audit/component_map.yml"))
          unless preview_map.selectors(@folder).empty?
            return ["preview", preview_map, Divergences.load(@preview.join("audit/divergences.yml"))]
          end
        end
        ["working tree", ComponentMap.load(@root.join("audit/component_map.yml")), Divergences.load(@root.join("audit/divergences.yml"))]
      end

      def theme
        @theme ||= Theme.compare(
          themes_ts: ShadcnAudit.workspace_dir.join("ui/apps/v4/registry/themes.ts"),
          rubyui_css: (@preview || @root).join("docs/app/assets/stylesheets/application.tailwind.css")
        )
      end

      def url(side, theme)
        template = (side == "rubyui") ? RubyuiPreview::URL_TEMPLATE : Sandbox::URL_TEMPLATE
        template.sub("{folder}", @folder).sub("{light|dark}", theme)
      end

      def observe_all(driver, states, selectors, slots)
        shadcn_selectors = selectors.keys.to_h { |part| [part, %([data-slot="#{slots[part]}"])] }
        THEMES.flat_map do |theme|
          states.map do |state|
            sides = SIDES.to_h do |side|
              facts = driver.observe(url: url(side, theme), state: state,
                selectors: (side == "rubyui") ? selectors : shadcn_selectors,
                screenshot_path: @run_dir.join(shot(state, side, theme)))
              facts = facts.merge("screenshot" => shot(state, side, theme)) if facts["reached"]
              [side, facts]
            end
            {"state" => state, "theme" => theme}.merge(sides)
          end
        end
      end

      def shot(state, side, theme) = "screens/#{@folder}-#{state}-#{side}-#{theme}.png"

      def probe_environment(driver)
        SIDES.to_h { |side| [side, THEMES.to_h { |theme| [theme, driver.environment(url(side, theme))] }] }
      end

      def environment_diffs(environment)
        keys = []
        diffs = THEMES.flat_map do |theme|
          r = environment["rubyui"][theme]
          s = environment["shadcn"][theme]
          (r.keys | s.keys).reject { |key| r[key] == s[key] }.map do |key|
            keys << (FONT_KEYS.include?(key) ? "font" : key)
            "#{key}: #{r[key]} vs #{s[key]} (#{theme})"
          end
        end
        [diffs, keys.uniq]
      end

      def pixel_diffs(observations)
        observations.select { |o| o["rubyui"]["reached"] && o["shadcn"]["reached"] }.to_h do |o|
          ["#{o["state"]}/#{o["theme"]}", pixel_diff(o)]
        end
      end

      def pixel_diff(observation)
        diff = "screens/#{@folder}-#{observation["state"]}-diff-#{observation["theme"]}.png"
        result = PixelDiff.compare(rubyui_png: @run_dir.join(observation["rubyui"]["screenshot"]).to_s,
          shadcn_png: @run_dir.join(observation["shadcn"]["screenshot"]).to_s, diff_png: @run_dir.join(diff).to_s)
        result.key?("diff") ? result.merge("diff" => diff) : result
      rescue ChunkyPNG::Exception, Errno::ENOENT => e
        {"error" => e.message}
      end

      def screenshots(observations)
        observations.select { |o| o["rubyui"]["reached"] && o["shadcn"]["reached"] }.map do |o|
          {"state" => "#{o["state"]} (#{o["theme"]})", "rubyui" => o["rubyui"]["screenshot"], "shadcn" => o["shadcn"]["screenshot"]}
        end
      end

      def missing_selector_line(part)
        {"dimension" => "Look", "status" => "inconclusive", "basis" => nil, "rubyui" => "", "shadcn" => "",
         "source" => "", "note" => "#{part}: no selector in component_map.yml"}
      end
    end
  end
end
