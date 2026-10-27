module ShadcnAudit
  # Compares shadcn's theme tokens (themes.ts) with RubyUI's CSS custom
  # properties. Only tokens shadcn defines are compared; RubyUI-only tokens
  # (warning, success, ...) are ignored.
  module Theme
    MODES = {"light" => ":root", "dark" => ".dark"}.freeze

    def self.compare(themes_ts:, rubyui_css:, name: "neutral")
      shadcn = shadcn_vars(File.read(themes_ts), name)
      css = File.read(rubyui_css).gsub(%r{/\*.*?\*/}m, "")
      diffs = MODES.flat_map do |mode, selector|
        rubyui = css_vars(css, selector)
        shadcn.fetch(mode, {}).filter_map do |token, value|
          next if rubyui[token] == value
          {"mode" => mode, "token" => token, "rubyui" => rubyui[token], "shadcn" => value}
        end
      end
      {"status" => diffs.empty? ? "pass" : "fail", "diffs" => diffs}
    end

    def self.normalize(value) = value.gsub(/\s+/, " ").strip

    # Extracts the body of the first `{ ... }` after `start`, balancing braces.
    def self.block_after(source, start)
      open = source.index("{", start) or return nil
      depth = 0
      (open...source.length).each do |i|
        depth += 1 if source[i] == "{"
        depth -= 1 if source[i] == "}"
        return source[(open + 1)...i] if depth.zero?
      end
      nil
    end

    def self.shadcn_vars(source, name)
      entry_start = source.index(/name:\s*"#{Regexp.escape(name)}"/) or raise ArgumentError, "theme #{name.inspect} not found"
      vars_start = source.index("cssVars", entry_start) or raise ArgumentError, "cssVars not found for #{name.inspect}"
      css_vars = block_after(source, vars_start) or raise ArgumentError, "cssVars block not closed for #{name.inspect}"
      MODES.keys.to_h do |mode|
        index = css_vars.index(/\b#{mode}:\s*\{/)
        body = index && block_after(css_vars, index)
        pairs = body ? ts_pairs(body) : {}
        raise ArgumentError, "theme #{name.inspect}: #{mode} tokens missing or empty in themes.ts" if pairs.empty?
        [mode, pairs]
      end
    end

    def self.ts_pairs(body)
      body.scan(/(?:"([\w-]+)"|([\w-]+))\s*:\s*"([^"]*)"/).to_h do |quoted, bare, value|
        [quoted || bare, normalize(value)]
      end
    end

    def self.css_vars(css, selector)
      start = css.index(/^#{Regexp.escape(selector)}\s*\{/) or return {}
      body = block_after(css, start) or return {}
      body.scan(/--([\w-]+)\s*:\s*([^;]+);/).to_h { |token, value| [token, normalize(value)] }
    end
  end
end
