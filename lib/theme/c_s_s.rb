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
          background: "0 0% 100%",
          foreground: "0 0% 3.9%",
          primary: "0 0% 9%",
          "primary-foreground": "0 0% 98%",
          secondary: "0 0% 96.1%",
          "secondary-foreground": "0 0% 9%",
          muted: "0 0% 96.1%",
          "muted-foreground": "0 0% 45.1%",
          accent: "0 0% 96.1%",
          "accent-foreground": "0 0% 9%",
          destructive: "350 89% 60%",
          "destructive-foreground": "0 0% 100%",
          warning: "38 92% 50%",
          "warning-foreground": "0 0% 100%",
          success: "87 100% 37%",
          "success-foreground": "0 0% 100%",
          border: "0 0% 89.8%",
          input: "0 0% 89.8%",
          ring: "0 0% 3.9%",
          radius: "0.5rem"
        },
        dark: {
          background: "0 0% 3.9%",
          foreground: "0 0% 98%",
          primary: "0 0% 98%",
          "primary-foreground": "0 0% 9%",
          secondary: "0 0% 18%",
          "secondary-foreground": "0 0% 98%",
          muted: "0 0% 18%",
          "muted-foreground": "0 0% 63.9%",
          accent: "0 0% 18%",
          "accent-foreground": "0 0% 98%",
          destructive: "350 89% 60%",
          "destructive-foreground": "0 0% 100%",
          warning: "38 92% 50%",
          "warning-foreground": "0 0% 100%",
          success: "84 81% 44%",
          "success-foreground": "0 0% 100%",
          border: "0 0% 18%",
          input: "0 0% 18%",
          ring: "0 0% 83.1%"
        }
      }
    end

    def self.red
      {
        root: {
          **default_root,
          primary: "0 84.2% 60.2%",
          "primary-foreground": "0 0% 98%",
          ring: "0 84.2% 60.2%"
        },
        dark: {
          **default_dark,
          primary: "0 84.2% 60.2%",
          "primary-foreground": "0 0% 100%",
          ring: "0 84.2% 60.2%"
        }
      }
    end

    def self.orange
      {
        root: {
          **default_root,
          primary: "24.6 95% 53.1%",
          "primary-foreground": "0 0% 98%",
          ring: "24.6 95% 53.1%"
        },
        dark: {
          **default_dark,
          primary: "24.6 95% 53.1%",
          "primary-foreground": "0 0% 100%",
          ring: "24.6 95% 53.1%"
        }
      }
    end

    def self.amber
      {
        root: {
          **default_root,
          primary: "37.7 92.1% 50.2%",
          "primary-foreground": "0 0% 98%",
          ring: "37.7 92.1% 50.2%"
        },
        dark: {
          **default_dark,
          primary: "37.7 92.1% 50.2%",
          "primary-foreground": "0 0% 100%",
          ring: "37.7 92.1% 50.2%"
        }
      }
    end

    def self.yellow
      {
        root: {
          **default_root,
          primary: "47.9 95.8% 53.1%",
          "primary-foreground": "26 83% 14%",
          ring: "47.9 95.8% 53.1%"
        },
        dark: {
          **default_dark,
          primary: "47.9 95.8% 53.1%",
          "primary-foreground": "0 0% 9%",
          ring: "47.9 95.8% 53.1%"
        }
      }
    end

    def self.lime
      {
        root: {
          **default_root,
          primary: "84 81% 44%",
          "primary-foreground": "0 0% 98%",
          ring: "84 81% 44%"
        },
        dark: {
          **default_dark,
          primary: "84 81% 44%",
          "primary-foreground": "0 0% 100%",
          ring: "84 81% 44%"
        }
      }
    end

    def self.green
      {
        root: {
          **default_root,
          primary: "142 71% 45%",
          "primary-foreground": "0 0% 98%",
          ring: "142 71% 45%"
        },
        dark: {
          **default_dark,
          primary: "142 71% 45%",
          "primary-foreground": "0 0% 100%",
          ring: "142 71% 45%"
        }
      }
    end

    def self.emerald
      {
        root: {
          **default_root,
          primary: "160 84% 39%",
          "primary-foreground": "0 0% 98%",
          ring: "160 84% 39%"
        },
        dark: {
          **default_dark,
          primary: "160 84% 39%",
          "primary-foreground": "0 0% 100%",
          ring: "160 84% 39%"
        }
      }
    end

    def self.teal
      {
        root: {
          **default_root,
          primary: "173 80% 40%",
          "primary-foreground": "0 0% 98%",
          ring: "173 80% 40%"
        },
        dark: {
          **default_dark,
          primary: "173 80% 40%",
          "primary-foreground": "0 0% 100%",
          ring: "173 80% 40%"
        }
      }
    end

    def self.cyan
      {
        root: {
          **default_root,
          primary: "189 94% 43%",
          "primary-foreground": "0 0% 98%",
          ring: "189 94% 43%"
        },
        dark: {
          **default_dark,
          primary: "189 94% 43%",
          "primary-foreground": "0 0% 100%",
          ring: "189 94% 43%"
        }
      }
    end

    def self.sky
      {
        root: {
          **default_root,
          primary: "198.6 88.7% 48.4%",
          "primary-foreground": "0 0% 98%",
          ring: "198.6 88.7% 48.4%"
        },
        dark: {
          **default_dark,
          primary: "198.6 88.7% 48.4%",
          "primary-foreground": "0 0% 100%",
          ring: "198.6 88.7% 48.4%"
        }
      }
    end

    def self.blue
      {
        root: {
          **default_root,
          primary: "217.2 91.2% 59.8%",
          "primary-foreground": "0 0% 98%",
          ring: "217.2 91.2% 59.8%"
        },
        dark: {
          **default_dark,
          primary: "217.2 91.2% 59.8%",
          "primary-foreground": "0 0% 100%",
          ring: "217.2 91.2% 59.8%"
        }
      }
    end

    def self.indigo
      {
        root: {
          **default_root,
          primary: "239 84% 67%",
          "primary-foreground": "0 0% 100%",
          ring: "239 84% 67%"
        },
        dark: {
          **default_dark,
          primary: "239 84% 67%",
          "primary-foreground": "0 0% 100%",
          ring: "239 84% 67%"
        }
      }
    end

    def self.violet
      {
        root: {
          **default_root,
          primary: "258 90% 66%",
          "primary-foreground": "0 0% 100%",
          ring: "258 90% 66%"
        },
        dark: {
          **default_dark,
          primary: "258 90% 66%",
          "primary-foreground": "0 0% 100%",
          ring: "258 90% 66%"
        }
      }
    end

    def self.purple
      {
        root: {
          **default_root,
          primary: "271 91% 65%",
          "primary-foreground": "0 0% 100%",
          ring: "271 91% 65%"
        },
        dark: {
          **default_dark,
          primary: "271 91% 65%",
          "primary-foreground": "0 0% 100%",
          ring: "271 91% 65%"
        }
      }
    end

    def self.fuchsia
      {
        root: {
          **default_root,
          primary: "292 84% 61%",
          "primary-foreground": "0 0% 100%",
          ring: "292 84% 61%"
        },
        dark: {
          **default_dark,
          primary: "292 84% 61%",
          "primary-foreground": "0 0% 100%",
          ring: "292 84% 61%"
        }
      }
    end

    def self.pink
      {
        root: {
          **default_root,
          primary: "330 81% 60%",
          "primary-foreground": "0 0% 100%",
          ring: "330 81% 60%"
        },
        dark: {
          **default_dark,
          primary: "330 81% 60%",
          "primary-foreground": "0 0% 100%",
          ring: "330 81% 60%"
        }
      }
    end

    def self.rose
      {
        root: {
          **default_root,
          primary: "350 89% 60%",
          "primary-foreground": "0 0% 100%",
          ring: "350 89% 60%"
        },
        dark: {
          **default_dark,
          primary: "350 89% 60%",
          "primary-foreground": "0 0% 100%",
          ring: "350 89% 60%"
        }
      }
    end

    def self.default_root
      {
        background: "0 0% 100%",
        foreground: "0 0% 3.9%",
        secondary: "0 0% 96.1%",
        "secondary-foreground": "0 0% 9%",
        muted: "0 0% 96.1%",
        "muted-foreground": "0 0% 45.1%",
        accent: "0 0% 96.1%",
        "accent-foreground": "0 0% 9%",
        destructive: "350 89% 60%",
        "destructive-foreground": "0 0% 100%",
        warning: "38 92% 50%",
        "warning-foreground": "0 0% 100%",
        success: "87 100% 37%",
        "success-foreground": "0 0% 100%",
        border: "0 0% 89.8%",
        input: "0 0% 89.8%",
        ring: "0 0% 3.9%",
        radius: "0.5rem"
      }
    end

    def self.default_dark
      {
        background: "0 0% 3.9%",
        foreground: "0 0% 98%",
        primary: "0 0% 98%",
        "primary-foreground": "0 0% 100%",
        secondary: "0 0% 18%",
        "secondary-foreground": "0 0% 98%",
        muted: "0 0% 18%",
        "muted-foreground": "0 0% 63.9%",
        accent: "0 0% 18%",
        "accent-foreground": "0 0% 98%",
        destructive: "350 89% 60%",
        "destructive-foreground": "0 0% 100%",
        warning: "38 92% 50%",
        "warning-foreground": "0 0% 100%",
        success: "84 81% 44%",
        "success-foreground": "0 0% 100%",
        border: "0 0% 18%",
        input: "0 0% 18%",
        ring: "0 0% 83.1%"
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
