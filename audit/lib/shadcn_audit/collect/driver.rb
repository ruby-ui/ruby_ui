module ShadcnAudit
  module Collect
    class BrowserError < StandardError; end

    # Drives headless Chromium through playwright-ruby-client and returns the
    # raw facts the Grader compares. One fresh page per observation.
    class Driver
      STATES = %w[closed open focus after-esc].freeze
      VIEWPORT = {width: 1280, height: 800}.freeze
      TIMEOUT_MS = 15_000
      MAX_TABS = 20
      INSTALL_HINT = "run `pnpm install && pnpm exec playwright install chromium` in audit/"
      SIDES = %w[top right bottom left].freeze
      STYLE_PROPS = (
        %w[color background-color] +
        SIDES.flat_map { |s| %W[border-#{s}-width border-#{s}-style border-#{s}-color] } +
        %w[top-left top-right bottom-right bottom-left].map { |c| "border-#{c}-radius" } +
        %w[box-shadow outline-width outline-style outline-color outline-offset] +
        SIDES.map { |s| "padding-#{s}" } +
        %w[gap row-gap column-gap width height font-family font-size font-weight line-height
          letter-spacing text-align text-decoration-line opacity display transform]
      ).freeze
      PROBES = File.read(File.expand_path("probes.js", __dir__))

      def self.open(audit_dir:)
        require "playwright"
        cli = File.join(audit_dir.to_s, "node_modules/.bin/playwright")
        raise BrowserError, "playwright not found at #{cli}: #{INSTALL_HINT}" unless File.executable?(cli)

        Playwright.create(playwright_cli_executable_path: cli) do |playwright|
          browser = begin
            playwright.chromium.launch(headless: true)
          rescue Playwright::Error => e
            raise BrowserError, "chromium failed to launch (#{e.message.lines.first.strip}): #{INSTALL_HINT}"
          end
          begin
            yield new(browser)
          ensure
            browser.close
          end
        end
      end

      def initialize(browser)
        @browser = browser
      end

      def environment(url)
        with_page(url) { |page| probe(page, "environment") }
      end

      # SideFacts: {"reached", "reason", "screenshot", "parts" => {part => [element]}}.
      def observe(url:, state:, selectors:, screenshot_path:)
        raise ArgumentError, "unknown state #{state.inspect}" unless STATES.include?(state)

        with_page(url) do |page|
          reason = reach(page, state)
          next unreached(reason) if reason

          probe(page, "settle")
          page.screenshot(path: screenshot_path.to_s, animations: "disabled", caret: "hide")
          parts = selectors.sort.to_h { |part, css| [part, elements(page, css)] }
          {"reached" => true, "reason" => nil, "screenshot" => screenshot_path.to_s, "parts" => parts}
        end
      rescue Playwright::Error => e
        unreached(e.message.lines.first.to_s.strip)
      end

      private

      def with_page(url)
        context = @browser.new_context(viewport: VIEWPORT, deviceScaleFactor: 1, reducedMotion: "reduce")
        page = context.new_page
        errors = []
        page.on("pageerror", ->(error) { errors << error.message })
        page.goto(url, waitUntil: "load", timeout: TIMEOUT_MS)
        return unreached("page error: #{errors.first.lines.first.strip}") unless errors.empty?

        yield page
      ensure
        context&.close
      end

      # nil when the state was reached, else the reason.
      def reach(page, state)
        return nil if state == "closed"

        trigger = page.locator("[data-audit-trigger]")
        return "no [data-audit-trigger]" if trigger.count.zero?

        if state == "focus"
          MAX_TABS.times do
            page.keyboard.press("Tab")
            return nil if probe(page, "triggerFocused")
          end
          return "trigger never received keyboard focus"
        end

        trigger.first.click(timeout: TIMEOUT_MS)
        if state == "after-esc"
          probe(page, "settle")
          page.keyboard.press("Escape")
        end
        nil
      end

      def elements(page, css)
        found = probe(page, "part", {selector: css, props: STYLE_PROPS, attrs: Grader::ARIA_ATTRS})
        all = page.locator(css)
        found.map do |el|
          {"styles" => el["styles"], "aria" => all.nth(el["index"]).aria_snapshot(timeout: TIMEOUT_MS), "attrs" => el["attrs"]}
        end
      end

      def probe(page, name, arg = nil)
        page.evaluate("(arg) => (#{PROBES})[#{name.to_json}](arg)", arg: arg)
      end

      def unreached(reason)
        {"reached" => false, "reason" => reason, "screenshot" => nil, "parts" => {}}
      end
    end
  end
end
