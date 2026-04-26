module Theme
  class CSS
    # Ruby UI specific variables that are not part of the standard shadcn theme
    RUBY_UI_SPECIFIC_VARS = %w[warning warning-foreground success success-foreground].freeze

    def self.retrieve(theme, with_directive: true, format: :css, exclude_ruby_ui_vars: false)
      theme_hash = send(theme)
      theme_hash = filter_ruby_ui_vars(theme_hash) if exclude_ruby_ui_vars

      case format
      when :css
        css = hash_to_css(theme_hash)
        with_directive ? wrap_with_directive(css) : css
      when :hash
        theme_hash
      else
        raise ArgumentError, "Invalid format: #{format}"
      end
    end

    def self.filter_ruby_ui_vars(theme_hash)
      theme_hash.transform_values do |properties|
        properties.reject { |key, _| RUBY_UI_SPECIFIC_VARS.include?(key.to_s) }
      end
    end

    def self.all_themes
      {
        default: default,
        neutral: neutral,
        red: red,
        orange: orange,
        amber: amber,
        yellow: yellow,
        lime: lime,
        green: green,
        emerald: emerald,
        teal: teal,
        cyan: cyan,
        sky: sky,
        blue: blue,
        indigo: indigo,
        violet: violet,
        purple: purple,
        fuchsia: fuchsia,
        pink: pink,
        rose: rose
      }
    end

    def self.default
      neutral
    end

    def self.neutral
      {
        root: {
          background: "oklch(1 0 0)",
          foreground: "oklch(0.145 0 0)",
          card: "oklch(1 0 0)",
          "card-foreground": "oklch(0.145 0 0)",
          popover: "oklch(1 0 0)",
          "popover-foreground": "oklch(0.145 0 0)",
          primary: "oklch(0.205 0 0)",
          "primary-foreground": "oklch(0.985 0 0)",
          secondary: "oklch(0.97 0 0)",
          "secondary-foreground": "oklch(0.205 0 0)",
          muted: "oklch(0.97 0 0)",
          "muted-foreground": "oklch(0.556 0 0)",
          accent: "oklch(0.97 0 0)",
          "accent-foreground": "oklch(0.205 0 0)",
          destructive: "oklch(0.577 0.245 27.325)",
          "destructive-foreground": "oklch(0.577 0.245 27.325)",
          border: "oklch(0.922 0 0)",
          input: "oklch(0.922 0 0)",
          ring: "oklch(0.708 0 0)",
          "chart-1": "oklch(0.646 0.222 41.116)",
          "chart-2": "oklch(0.6 0.118 184.704)",
          "chart-3": "oklch(0.398 0.07 227.392)",
          "chart-4": "oklch(0.828 0.189 84.429)",
          "chart-5": "oklch(0.769 0.188 70.08)",
          radius: "0.625rem",
          sidebar: "oklch(0.985 0 0)",
          "sidebar-foreground": "oklch(0.145 0 0)",
          "sidebar-primary": "oklch(0.205 0 0)",
          "sidebar-primary-foreground": "oklch(0.985 0 0)",
          "sidebar-accent": "oklch(0.97 0 0)",
          "sidebar-accent-foreground": "oklch(0.205 0 0)",
          "sidebar-border": "oklch(0.922 0 0)",
          "sidebar-ring": "oklch(0.708 0 0)",
          warning: "hsl(38 92% 50%)",
          "warning-foreground": "hsl(0 0% 100%)",
          success: "hsl(87 100% 37%)",
          "success-foreground": "hsl(0 0% 100%)"
        },
        dark: {
          background: "oklch(0.145 0 0)",
          foreground: "oklch(0.985 0 0)",
          card: "oklch(0.205 0 0)",
          "card-foreground": "oklch(0.985 0 0)",
          popover: "oklch(0.205 0 0)",
          "popover-foreground": "oklch(0.985 0 0)",
          primary: "oklch(0.922 0 0)",
          "primary-foreground": "oklch(0.205 0 0)",
          secondary: "oklch(0.269 0 0)",
          "secondary-foreground": "oklch(0.985 0 0)",
          muted: "oklch(0.269 0 0)",
          "muted-foreground": "oklch(0.708 0 0)",
          accent: "oklch(0.269 0 0)",
          "accent-foreground": "oklch(0.985 0 0)",
          destructive: "oklch(0.704 0.191 22.216)",
          "destructive-foreground": "oklch(0.637 0.237 25.331)",
          border: "oklch(1 0 0 / 10%)",
          input: "oklch(1 0 0 / 15%)",
          ring: "oklch(0.556 0 0)",
          "chart-1": "oklch(0.488 0.243 264.376)",
          "chart-2": "oklch(0.696 0.17 162.48)",
          "chart-3": "oklch(0.769 0.188 70.08)",
          "chart-4": "oklch(0.627 0.265 303.9)",
          "chart-5": "oklch(0.645 0.246 16.439)",
          sidebar: "oklch(0.205 0 0)",
          "sidebar-foreground": "oklch(0.985 0 0)",
          "sidebar-primary": "oklch(0.488 0.243 264.376)",
          "sidebar-primary-foreground": "oklch(0.985 0 0)",
          "sidebar-accent": "oklch(0.269 0 0)",
          "sidebar-accent-foreground": "oklch(0.985 0 0)",
          "sidebar-border": "oklch(1 0 0 / 10%)",
          "sidebar-ring": "oklch(0.556 0 0)",
          warning: "hsl(38 92% 50%)",
          "warning-foreground": "hsl(0 0% 100%)",
          success: "hsl(84 81% 44%)",
          "success-foreground": "hsl(0 0% 100%)"
        }
      }
    end

    def self.red
      {
        root: {
          **default_root,
          primary: "oklch(0.577 0.245 27.325)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.577 0.245 27.325)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.396 0.141 25.723)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.396 0.141 25.723)"
        }
      }
    end

    def self.orange
      {
        root: {
          **default_root,
          primary: "oklch(0.7048 0.1868 47.6)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.7048 0.1868 47.6)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.7048 0.1868 47.6)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.7048 0.1868 47.6)"
        }
      }
    end

    def self.amber
      {
        root: {
          **default_root,
          primary: "oklch(0.7686 0.1646 70.11)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.7686 0.1646 70.11)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.7686 0.1646 70.11)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.7686 0.1646 70.11)"
        }
      }
    end

    def self.yellow
      {
        root: {
          **default_root,
          primary: "oklch(0.8601 0.173 91.84)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.8601 0.173 91.84)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.8601 0.173 91.84)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.8601 0.173 91.84)"
        }
      }
    end

    def self.lime
      {
        root: {
          **default_root,
          primary: "oklch(0.765 0.2044 131.05)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.765 0.2044 131.05)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.765 0.2044 131.05)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.765 0.2044 131.05)"
        }
      }
    end

    def self.green
      {
        root: {
          **default_root,
          primary: "oklch(0.7205 0.192 149.49)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.7205 0.192 149.49)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.7205 0.192 149.49)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.7205 0.192 149.49)"
        }
      }
    end

    def self.emerald
      {
        root: {
          **default_root,
          primary: "oklch(0.6902 0.1481 162.37)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6902 0.1481 162.37)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.6902 0.1481 162.37)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6902 0.1481 162.37)"
        }
      }
    end

    def self.teal
      {
        root: {
          **default_root,
          primary: "oklch(0.7023 0.1232 181.8)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.7023 0.1232 181.8)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.7023 0.1232 181.8)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.7023 0.1232 181.8)"
        }
      }
    end

    def self.cyan
      {
        root: {
          **default_root,
          primary: "oklch(0.7147 0.126 215.83)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.7147 0.126 215.83)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.7147 0.126 215.83)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.7147 0.126 215.83)"
        }
      }
    end

    def self.sky
      {
        root: {
          **default_root,
          primary: "oklch(0.6847 0.1478 237.27)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6847 0.1478 237.27)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.6847 0.1478 237.27)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6847 0.1478 237.27)"
        }
      }
    end

    def self.blue
      {
        root: {
          **default_root,
          primary: "oklch(0.6232 0.1879 259.8)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6232 0.1879 259.8)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.6232 0.1879 259.8)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6232 0.1879 259.8)"
        }
      }
    end

    def self.indigo
      {
        root: {
          **default_root,
          primary: "oklch(0.5875 0.2039 277.36)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.5875 0.2039 277.36)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.5875 0.2039 277.36)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.5875 0.2039 277.36)"
        }
      }
    end

    def self.violet
      {
        root: {
          **default_root,
          primary: "oklch(0.6016 0.2214 292.23)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6016 0.2214 292.23)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.6016 0.2214 292.23)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6016 0.2214 292.23)"
        }
      }
    end

    def self.purple
      {
        root: {
          **default_root,
          primary: "oklch(0.6268 0.2332 304.11)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6268 0.2332 304.11)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.6268 0.2332 304.11)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6268 0.2332 304.11)"
        }
      }
    end

    def self.fuchsia
      {
        root: {
          **default_root,
          primary: "oklch(0.6683 0.2569 322.02)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6683 0.2569 322.02)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.6683 0.2569 322.02)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6683 0.2569 322.02)"
        }
      }
    end

    def self.pink
      {
        root: {
          **default_root,
          primary: "oklch(0.6538 0.2133 354.06)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6538 0.2133 354.06)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.6538 0.2133 354.06)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6538 0.2133 354.06)"
        }
      }
    end

    def self.rose
      {
        root: {
          **default_root,
          primary: "oklch(0.6437 0.2159 16.81)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6437 0.2159 16.81)"
        },
        dark: {
          **default_dark,
          primary: "oklch(0.6437 0.2159 16.81)",
          "primary-foreground": "oklch(0.985 0 0)",
          ring: "oklch(0.6437 0.2159 16.81)"
        }
      }
    end

    def self.default_root
      {
        background: "oklch(1 0 0)",
        foreground: "oklch(0.145 0 0)",
        card: "oklch(1 0 0)",
        "card-foreground": "oklch(0.145 0 0)",
        popover: "oklch(1 0 0)",
        "popover-foreground": "oklch(0.145 0 0)",
        secondary: "oklch(0.97 0 0)",
        "secondary-foreground": "oklch(0.205 0 0)",
        muted: "oklch(0.97 0 0)",
        "muted-foreground": "oklch(0.556 0 0)",
        accent: "oklch(0.97 0 0)",
        "accent-foreground": "oklch(0.205 0 0)",
        destructive: "oklch(0.577 0.245 27.325)",
        "destructive-foreground": "oklch(0.577 0.245 27.325)",
        border: "oklch(0.922 0 0)",
        input: "oklch(0.922 0 0)",
        ring: "oklch(0.708 0 0)",
        "chart-1": "oklch(0.646 0.222 41.116)",
        "chart-2": "oklch(0.6 0.118 184.704)",
        "chart-3": "oklch(0.398 0.07 227.392)",
        "chart-4": "oklch(0.828 0.189 84.429)",
        "chart-5": "oklch(0.769 0.188 70.08)",
        radius: "0.625rem",
        sidebar: "oklch(0.985 0 0)",
        "sidebar-foreground": "oklch(0.145 0 0)",
        "sidebar-primary": "oklch(0.205 0 0)",
        "sidebar-primary-foreground": "oklch(0.985 0 0)",
        "sidebar-accent": "oklch(0.97 0 0)",
        "sidebar-accent-foreground": "oklch(0.205 0 0)",
        "sidebar-border": "oklch(0.922 0 0)",
        "sidebar-ring": "oklch(0.708 0 0)",
        warning: "hsl(38 92% 50%)",
        "warning-foreground": "hsl(0 0% 100%)",
        success: "hsl(87 100% 37%)",
        "success-foreground": "hsl(0 0% 100%)"
      }
    end

    def self.default_dark
      {
        background: "oklch(0.145 0 0)",
        foreground: "oklch(0.985 0 0)",
        card: "oklch(0.205 0 0)",
        "card-foreground": "oklch(0.985 0 0)",
        popover: "oklch(0.205 0 0)",
        "popover-foreground": "oklch(0.985 0 0)",
        primary: "oklch(0.922 0 0)",
        "primary-foreground": "oklch(0.205 0 0)",
        secondary: "oklch(0.269 0 0)",
        "secondary-foreground": "oklch(0.985 0 0)",
        muted: "oklch(0.269 0 0)",
        "muted-foreground": "oklch(0.708 0 0)",
        accent: "oklch(0.269 0 0)",
        "accent-foreground": "oklch(0.985 0 0)",
        destructive: "oklch(0.704 0.191 22.216)",
        "destructive-foreground": "oklch(0.637 0.237 25.331)",
        border: "oklch(1 0 0 / 10%)",
        input: "oklch(1 0 0 / 15%)",
        ring: "oklch(0.556 0 0)",
        "chart-1": "oklch(0.488 0.243 264.376)",
        "chart-2": "oklch(0.696 0.17 162.48)",
        "chart-3": "oklch(0.769 0.188 70.08)",
        "chart-4": "oklch(0.627 0.265 303.9)",
        "chart-5": "oklch(0.645 0.246 16.439)",
        sidebar: "oklch(0.205 0 0)",
        "sidebar-foreground": "oklch(0.985 0 0)",
        "sidebar-primary": "oklch(0.488 0.243 264.376)",
        "sidebar-primary-foreground": "oklch(0.985 0 0)",
        "sidebar-accent": "oklch(0.269 0 0)",
        "sidebar-accent-foreground": "oklch(0.985 0 0)",
        "sidebar-border": "oklch(1 0 0 / 10%)",
        "sidebar-ring": "oklch(0.556 0 0)",
        warning: "hsl(38 92% 50%)",
        "warning-foreground": "hsl(0 0% 100%)",
        success: "hsl(84 81% 44%)",
        "success-foreground": "hsl(0 0% 100%)"
      }
    end

    def self.hash_to_css(hash)
      hash.map do |selector, properties|
        "#{format_selector(selector)} {\n" + properties.map { |property, value| "    --#{property}: #{value};" }.join("\n") + "\n  }"
      end.join("\n")
    end

    def self.format_selector(selector)
      case selector
      when :root then ":root"
      when :dark then "  .dark" # Indentation is important here
      else
        raise ArgumentError, "Invalid selector: #{selector}"
      end
    end

    def self.wrap_with_directive(css)
      # Tailwind 4: :root and .dark selectors should NOT be wrapped in @layer base
      # This ensures CSS variables are properly accessible to @theme inline
      css
    end
  end
end
