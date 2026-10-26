module ShadcnAudit
  # Computes, per part (keyed by data-slot), the effective Tailwind classes a
  # shadcn Base UI component renders: the literal classes in its .tsx plus the
  # @apply body of every cn-* class it references in the style CSS.
  #
  # No JS parser: the .tsx files are prettier-formatted, so we scan strings and
  # match brackets. Whatever the scanner cannot read reliably is reported in
  # "warnings" instead of being dropped silently.
  class Reference
    CN_TOKEN = /\Acn-[\w-]+\z/
    OPENERS = {"(" => ")", "{" => "}", "[" => "]"}.freeze
    # cn-* tokens with no rule in any style CSS. shadcn defines them nowhere in
    # the registry; --font-heading is a theme variable (registry/fonts.ts), so
    # the token stands for the `font-heading` utility. Inferred, always warned.
    ALIASES = {"cn-font-heading" => ["font-heading"]}.freeze
    IGNORED_PROPS = %w[className children].freeze

    def initialize(registry_dir:, style: "vega")
      @registry_dir = Pathname.new(registry_dir)
      @style = style
    end

    def for(shadcn_name)
      file = "bases/base/ui/#{shadcn_name}.tsx"
      result = {"file" => file, "style_file" => "styles/style-#{@style}.css",
                "parts" => {}, "variants" => {}, "unresolved" => [], "warnings" => [], "missing" => false}
      path = @registry_dir.join(file)
      return result.merge("missing" => true) unless path.file?

      source = path.read
      warnings = result["warnings"]
      result["variants"] = scan_variants(source, warnings)
      cva_names = result["variants"].keys.to_set
      scan_parts(source, cva_names, warnings).each do |slot, part|
        result["parts"][slot] = part
      end
      resolve!(result)
      result
    end

    private

    # ---- CSS ------------------------------------------------------------

    def css_rules
      @css_rules ||= begin
        path = @registry_dir.join("styles/style-#{@style}.css")
        path.file? ? parse_css(path.read) : {plain: {}, counts: {}, other: {}}
      end
    end

    # Walks braces keeping a selector stack; collects @apply tokens per cn-*
    # class. Only a plain `.cn-x {` rule is applied; any other selector that
    # mentions a cn-* class is recorded in :other so it can be reported.
    def parse_css(text)
      plain = Hash.new { |h, k| h[k] = [] }
      counts = Hash.new(0)
      other = Hash.new { |h, k| h[k] = [] }
      stack = []
      buf = +""
      handle = lambda do |stmt|
        next unless stmt.start_with?("@apply")
        idx = stack.index { |s| s.include?(".cn-") } or next
        selector = stack[idx]
        tokens = stmt.delete_prefix("@apply").split
        if idx == stack.size - 1 && selector.match?(/\A\.cn-[\w-]+\z/) && stack.none? { |s| s.start_with?("@") }
          name = selector.delete_prefix(".")
          counts[name] += 1
          plain[name].concat(tokens)
        else
          path = stack[idx..].join(" { ")
          selector.scan(/\.(cn-[\w-]+)/).flatten.each { |c| other[c] << path }
        end
      end
      text.gsub(%r{/\*.*?\*/}m, "").each_char do |ch|
        case ch
        when "{"
          stack.push(buf.strip)
          buf = +""
        when "}"
          handle.call(buf.strip)
          stack.pop
          buf = +""
        when ";"
          handle.call(buf.strip)
          buf = +""
        else
          buf << ch
        end
      end
      {plain: plain, counts: counts, other: other}
    end

    def resolve!(result)
      rules = css_rules
      used = []
      each_class_set(result) do |set|
        set["cn"] = set["inline"].grep(CN_TOKEN).uniq
        used.concat(set["cn"])
        set["resolved"] = set["cn"].flat_map { |c| rules[:plain].fetch(c) { ALIASES.fetch(c, []) } }.uniq
        set["effective"] = (set["inline"].reject { |t| t.match?(CN_TOKEN) } + set["resolved"]).uniq
      end
      used.uniq!
      result["unresolved"] = used.reject { |c| rules[:plain].key?(c) || ALIASES.key?(c) }
      used.each do |c|
        if ALIASES.key?(c) && !rules[:plain].key?(c)
          result["warnings"] << "#{c}: no rule in style CSS; mapped to `#{ALIASES[c].join(" ")}` (inferred from --font-heading theme variable)"
        end
        result["warnings"] << "#{c}: #{rules[:counts][c]} plain rules in style CSS, all concatenated" if rules[:counts][c].to_i > 1
        Array(rules[:other][c]).each do |sel|
          result["warnings"] << "#{c}: also under non-plain selector `#{sel}` in style CSS (not applied)"
        end
      end
      result["variants"].each_value do |groups|
        groups.each_value { |names| names.transform_values! { |set| set["effective"] } }
      end
      result["warnings"].uniq!
    end

    # Yields every {"inline" => [...]} holder (parts, their duplicates, cva
    # variant entries) so cn-* resolution happens in one place.
    def each_class_set(result, &block)
      result["parts"].each_value do |part|
        block.call(part)
        Array(part["also"]).each(&block)
      end
      result["variants"].each_value do |groups|
        groups.each_value { |names| names.each_value(&block) }
      end
    end

    # ---- TSX: string scanning helpers -----------------------------------

    # Index of the bracket closing the one at `open`, quote- and nesting-aware.
    def match_close(str, open)
      depth = 0
      i = open
      while i < str.length
        ch = str[i]
        if ch == '"' || ch == "'" || ch == "`"
          i = skip_string(str, i)
          next
        elsif OPENERS.key?(ch)
          depth += 1
        elsif OPENERS.value?(ch)
          depth -= 1
          return i if depth.zero?
        end
        i += 1
      end
      nil
    end

    # Index just after the string literal starting at `i`.
    def skip_string(str, i)
      quote = str[i]
      i += 1
      while i < str.length && str[i] != quote
        i += (str[i] == "\\") ? 2 : 1
      end
      i + 1
    end

    def split_top_level(str)
      parts = []
      buf = +""
      depth = 0
      i = 0
      while i < str.length
        ch = str[i]
        if ch == '"' || ch == "'" || ch == "`"
          j = skip_string(str, i)
          buf << str[i...j]
          i = j
          next
        end
        depth += 1 if OPENERS.key?(ch)
        depth -= 1 if OPENERS.value?(ch)
        if ch == "," && depth.zero?
          parts << buf
          buf = +""
        else
          buf << ch
        end
        i += 1
      end
      parts << buf
      parts.map(&:strip).reject(&:empty?)
    end

    # Static string literals of an expression (template literals with ${} are
    # not static: reported through the skeleton check instead).
    def string_literals(expr)
      literals = []
      i = 0
      while i < expr.length
        if ['"', "'", "`"].include?(expr[i])
          j = skip_string(expr, i)
          literals << expr[(i + 1)...(j - 1)]
          i = j
        else
          i += 1
        end
      end
      literals
    end

    # ---- TSX: parts -----------------------------------------------------

    def scan_parts(source, cva_names, warnings)
      parts = {}
      function_blocks(source).each do |name, block|
        props = function_props(block)
        claimed = []
        block.to_enum(:scan, /data-slot="([^"]+)"/).map { Regexp.last_match }.each do |m|
          slot = m[1]
          tag = enclosing_tag(block, m.begin(0))
          unless tag
            warnings << "#{slot} (#{name}): JSX tag around data-slot not found"
            next
          end
          set = class_set_for_tag(tag, "#{slot} (#{name})", cva_names, warnings)
          claimed.concat(set["inline"])
          part = set.merge("function" => name, "props" => props)
          add_part(parts, slot, part, name)
        end
        orphans = block.scan(/"([^"]*\bcn-[^"]*)"/).flatten.flat_map(&:split).grep(CN_TOKEN).uniq - claimed
        orphans.each do |c|
          warnings << "#{c} (#{name}): referenced outside any data-slot element, not attributed to a part"
        end
      end
      parts
    end

    # A slot can appear twice (the real component, plus a usage embedded in
    # another component). The part named after the slot wins; others go to
    # "also" so no class is dropped.
    def add_part(parts, slot, part, function_name)
      existing = parts[slot]
      return parts[slot] = part unless existing
      canonical = function_name == slot.split("-").map(&:capitalize).join
      keep, extra = canonical ? [part, existing] : [existing, part]
      keep = keep.dup
      keep["also"] = Array(keep["also"]) + [extra.except("also")]
      parts[slot] = keep
    end

    def function_blocks(source)
      starts = source.to_enum(:scan, /^function (\w+)\(/).map { Regexp.last_match }
      starts.map do |m|
        close = source.index("\n}\n", m.begin(0)) || source.length
        [m[1], source[m.begin(0)...close]]
      end
    end

    def function_props(block)
      open = block.index("(")
      close = match_close(block, open) or return []
      params = block[(open + 1)...close].strip
      return [] unless params.start_with?("{")
      inner = params[1...match_close(params, 0)]
      split_top_level(inner).filter_map do |item|
        next if item.start_with?("...")
        name = item[/\A[\w$]+/]
        name unless name.nil? || IGNORED_PROPS.include?(name)
      end
    end

    # Text of the JSX opening tag that contains `index`.
    def enclosing_tag(block, index)
      from = index
      while (start = block.rindex("<", from))
        if block[start + 1].match?(/[A-Za-z]/)
          stop = tag_end(block, start)
          return block[start..stop] if stop && stop >= index
        end
        from = start - 1
        return nil if from < 0
      end
      nil
    end

    def tag_end(str, start)
      depth = 0
      i = start
      while i < str.length
        ch = str[i]
        if ch == '"' || ch == "'" || ch == "`"
          i = skip_string(str, i)
          next
        end
        depth += 1 if ch == "{"
        depth -= 1 if ch == "}"
        return i if ch == ">" && depth.zero? && str[i - 1] != "="
        i += 1
      end
      nil
    end

    # Value text (string contents, or brace expression) of attribute `attr`
    # at the top level of an opening tag; nil when absent.
    def top_level_attr(tag, attr)
      depth = 0
      i = 0
      while i < tag.length
        ch = tag[i]
        if depth.zero? && tag[i, attr.length + 1] == "#{attr}=" && tag[i - 1] =~ /\s/
          vstart = i + attr.length + 1
          if tag[vstart] == '"'
            return [:string, tag[(vstart + 1)...(skip_string(tag, vstart) - 1)]]
          elsif tag[vstart] == "{"
            return [:expr, tag[(vstart + 1)...match_close(tag, vstart)]]
          end
        end
        if ch == '"' || ch == "'" || ch == "`"
          i = skip_string(tag, i)
          next
        end
        depth += 1 if ch == "{"
        depth -= 1 if ch == "}"
        i += 1
      end
      nil
    end

    def class_set_for_tag(tag, label, cva_names, warnings)
      warn_if_wrapped_component(tag, label, warnings)
      kind, value = top_level_attr(tag, "className")
      unless kind
        render_kind, render = top_level_attr(tag, "render")
        if render_kind == :expr && (inner = render.index("<")) && (inner_tag = enclosing_tag(render, inner + 1))
          kind, value = top_level_attr(inner_tag, "className")
          warnings << "#{label}: classes read from the render prop element" if kind
        end
      end
      return {"inline" => []} unless kind
      return {"inline" => tokens(value)} if kind == :string
      {"inline" => class_expression_tokens(value, label, cva_names, warnings)}
    end

    # A part rendered through another shadcn component (<Button ...>, or a
    # render={<Button />} prop) also gets that component's classes at runtime;
    # we only extract the part's own, so say so.
    def warn_if_wrapped_component(tag, label, warnings)
      components = []
      components << tag[/\A<([A-Z]\w*)[\s>\/]/, 1]
      render_kind, render = top_level_attr(tag, "render")
      components << render[/<([A-Z]\w*)[\s>\/]/, 1] if render_kind == :expr
      components.compact.reject { |c| c.end_with?("Primitive") }.each do |c|
        warnings << "#{label}: rendered through <#{c}>; its own classes are not included"
      end
    end

    def tokens(string) = string.split

    # `cn("a", "b", className)` is the supported shape; a cva call inside cn
    # contributes the cva base string. Anything else (conditionals, template
    # interpolation, other calls) is warned about but its literals are kept.
    def class_expression_tokens(expr, label, cva_names, warnings)
      skeleton = expr.dup
      found = []
      cva_names.each do |cva|
        while (m = skeleton.match(/\b#{Regexp.escape(cva)}\(/))
          close = match_close(skeleton, m.end(0) - 1) or break
          found << cva
          skeleton[m.begin(0)..close] = "V"
        end
      end
      leftover = skeleton.gsub(/"(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'|`(?:[^`\\]|\\.)*`/m, "S")
      leftover = leftover.gsub(/\bcn\(|\bclassName\b|[S V,)\s]/, "")
      unless leftover.empty?
        warnings << "#{label}: className expression not fully understood (#{expr.gsub(/\s+/, " ").strip[0, 120]})"
      end
      if skeleton.include?("${")
        warnings << "#{label}: template literal with interpolation in className; dynamic part not extracted"
      end
      literals = string_literals(skeleton).flat_map(&:split)
      cva_tokens = found.flat_map { |f| @cva_bases.fetch(f, []) }
      literals + cva_tokens
    end

    # ---- TSX: cva -------------------------------------------------------

    def scan_variants(source, warnings)
      @cva_bases = {}
      variants = {}
      source.to_enum(:scan, /(?:const|let)\s+(\w+)\s*=\s*cva\(/).map { Regexp.last_match }.each do |m|
        name = m[1]
        open = m.end(0) - 1
        close = match_close(source, open) or next
        args = split_top_level(source[(open + 1)...close])
        @cva_bases[name] = string_literals(args.first.to_s).flat_map(&:split) if args.first.to_s.start_with?('"')
        config = args[1].to_s
        warnings << "#{name}: compoundVariants present, not extracted" if config.include?("compoundVariants")
        variants[name] = parse_variant_groups(name, config, warnings)
      end
      variants
    end

    def parse_variant_groups(cva_name, config, warnings)
      key = config.index(/\bvariants:\s*\{/) or return {}
      open = config.index("{", key)
      body = config[(open + 1)...match_close(config, open)]
      split_top_level(body).each_with_object({}) do |group, out|
        group_name, rest = group.split(":", 2)
        next unless rest&.strip&.start_with?("{")
        entries = rest.strip
        inner = entries[1...match_close(entries, 0)]
        out[unquote(group_name)] = split_top_level(inner).each_with_object({}) do |entry, h|
          entry_name, value = entry.split(":", 2)
          literals = string_literals(value.to_s)
          if literals.empty? || value.to_s.strip !~ /\A["'`]/
            warnings << "#{cva_name}.#{unquote(group_name)}.#{unquote(entry_name)}: value is not a plain string, not extracted"
          end
          h[unquote(entry_name)] = {"inline" => literals.flat_map(&:split)}
        end
      end
    end

    def unquote(str) = str.strip.delete_prefix('"').delete_suffix('"')
  end
end
