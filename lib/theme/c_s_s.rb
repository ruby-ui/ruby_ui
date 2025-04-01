module Theme
  class CSS
    def self.retrieve(theme, with_directive: true, format: :css)
      theme_hash = send(theme)

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
          card: "oklch(0.145 0 0)",
          "card-foreground": "oklch(0.985 0 0)",
          popover: "oklch(0.145 0 0)",
          "popover-foreground": "oklch(0.985 0 0)",
          primary: "oklch(0.985 0 0)",
          "primary-foreground": "oklch(0.205 0 0)",
          secondary: "oklch(0.269 0 0)",
          "secondary-foreground": "oklch(0.985 0 0)",
          muted: "oklch(0.269 0 0)",
          "muted-foreground": "oklch(0.708 0 0)",
          accent: "oklch(0.269 0 0)",
          "accent-foreground": "oklch(0.985 0 0)",
          destructive: "oklch(0.396 0.141 25.723)",
          "destructive-foreground": "oklch(0.637 0.237 25.331)",
          border: "oklch(0.269 0 0)",
          input: "oklch(0.269 0 0)",
          ring: "oklch(0.439 0 0)",
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
          "sidebar-border": "oklch(0.269 0 0)",
          "sidebar-ring": "oklch(0.439 0 0)",
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

    def self.amber
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

    def self.yellow
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

    def self.lime
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

    def self.green
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

    def self.emerald
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

    def self.teal
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

    def self.cyan
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

    def self.sky
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

    def self.blue
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

    def self.indigo
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

    def self.violet
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

    def self.purple
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

    def self.fuchsia
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

    def self.pink
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

    def self.rose
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
        card: "oklch(0.145 0 0)",
        "card-foreground": "oklch(0.985 0 0)",
        popover: "oklch(0.145 0 0)",
        "popover-foreground": "oklch(0.985 0 0)",
        primary: "oklch(0.985 0 0)",
        "primary-foreground": "oklch(0.205 0 0)",
        secondary: "oklch(0.269 0 0)",
        "secondary-foreground": "oklch(0.985 0 0)",
        muted: "oklch(0.269 0 0)",
        "muted-foreground": "oklch(0.708 0 0)",
        accent: "oklch(0.269 0 0)",
        "accent-foreground": "oklch(0.985 0 0)",
        destructive: "oklch(0.396 0.141 25.723)",
        "destructive-foreground": "oklch(0.637 0.237 25.331)",
        border: "oklch(0.269 0 0)",
        input: "oklch(0.269 0 0)",
        ring: "oklch(0.439 0 0)",
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
        "sidebar-border": "oklch(0.269 0 0)",
        "sidebar-ring": "oklch(0.439 0 0)",
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
      <<~CSS
        @layer base {
          #{css}
        }
      CSS
    end
  end
end
