# frozen_string_literal: true

class Views::Docs::GettingStarted::Theming < Views::Base
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Theming", description: "Using CSS variables for theming.")

      div(class: "space-y-4") do
        Components.Heading(level: 2) { "Introduction" }
        Text do
          plain "RubyUI uses CSS Variables like "
          InlineCode { "--primary: oklch(0.205 0 0)" }
          plain " for theming. This approach is inspired by "
          InlineLink(href: "https://ui.shadcn.com") { "shadcn/ui" }
          plain " and allows you to easily customize the look and feel of your application."
        end
        # List the 2 benefits. That we can use CSS variables to change the style, without changing the tailwindcss classes used
        # And that we can change the style of a particular tailwindcss class for both light and dark mode, without having to duplicate the tailwindcss class
        # For instance, bg-primary will work for both light and dark mode, without having to define both bg-primary and dark:bg-primary-dark (or something else like that)
        Text do
          plain "There are "
          span(class: "font-medium") { "two main benefits" }
          plain " to this approach:"
        end
        Components.TypographyList do
          Components.TypographyListItem do
            span(class: "font-medium") { "Easily customisable design " }
            plain "by updating CSS variables, without having to update the RubyUI component."
          end
          Components.TypographyListItem do
            span(class: "font-medium") { "Simpler implementation " }
            plain " for both light and dark mode, by not having to duplicate the TailwindCSS class (e.g. "
            InlineCode { "bg-primary" }
            plain " will work for both light and dark mode, without having to define both "
            InlineCode { "bg-primary" }
            plain " and "
            InlineCode { "dark:bg-primary-dark" }
            plain " - Or something else like that)."
          end
        end
      end

      div(class: "space-y-4") do
        Heading(level: 2) { "Convention" }
        Text do
          plain "We use a simple "
          InlineCode { "background" }
          plain " and "
          InlineCode { "foreground" }
          plain " convention for colors. The "
          InlineCode { "background" }
          plain " variable is used for the background color of the component and the "
          InlineCode { "foreground" }
          plain " variable is used for the text color. This is similar to other component libraries that are popular in React and elsewhere, and it works well in our experience."
        end
        Alert(class: "bg-transparent") do
          AlertDescription do
            plain "The "
            InlineCode { "background" }
            plain " suffix is omitted when the variable is used for the background color of the component."
          end
        end
        Text { "Given the following CSS variables:" }
        code = <<~CODE
          --primary: oklch(0.205 0 0);
          --primary-foreground: oklch(0.985 0 0);
        CODE
        Codeblock(code, syntax: :css)
        Text do
          plain "The "
          InlineCode { "background" }
          plain " color of the following component will be "
          InlineCode { "var(--primary)" }
          plain " and the "
          InlineCode { "foreground" }
          plain " color will be "
          InlineCode { "var(--primary-foreground)" }
          plain "."
        end
        code = <<~CODE
          <div className="bg-primary text-primary-foreground">We love Ruby</div>
        CODE
        Codeblock(code, syntax: :html)
        Alert(class: "bg-transparent") do
          AlertDescription do
            span(class: "font-medium") { "RubyUI uses oklch color format" }
            plain ", the same format used by shadcn/ui. See the "
            InlineLink(href: "https://tailwindcss.com/docs/customizing-colors#using-css-variables") { "Tailwind CSS documentation" }
            plain " for more information."
          end
        end
      end

      div(class: "space-y-4") do
        Heading(level: 2) { "List of variables" }
        Text { "Here's the list of variables available for customization:" }
        Card(class: "space-y-4 shadow-none p-4 md:p-6") do
          css_variables
        end
      end

      div(class: "space-y-4") do
        Heading(level: 2) { "Adding new colors" }
        Text do
          plain "To add new colors, you need to add them to your "
          InlineCode { "application.tailwind.css" }
          plain " file and to your "
          InlineCode { "tailwind.config.js" }
          plain " file."
        end
        adding_a_color
      end

      div(class: "space-y-4") do
        Heading(level: 2) { "Color format (oklch)" }
        Text do
          plain "RubyUI uses "
          InlineLink(href: "https://developer.mozilla.org/en-US/docs/Web/CSS/color_value/oklch") { "oklch colors" }
          plain " as the default color format. This is the same format used by "
          InlineLink(href: "https://ui.shadcn.com") { "shadcn/ui" }
          plain " and provides better perceptual uniformity and wider color gamut support."
        end
        Text do
          plain "While "
          InlineCode { "oklch" }
          plain " is recommended, you can also use other color formats such as "
          InlineCode { "hsl" }
          plain ", "
          InlineCode { "rgb" }
          plain ", or "
          InlineCode { "rgba" }
          plain ". See the "
          InlineLink(href: "https://tailwindcss.com/docs/customizing-colors#using-css-variables") { "Tailwind CSS documentation" }
          plain " for more information."
        end
      end

      div(class: "space-y-4") do
        Heading(level: 2) { "shadcn/ui themes" }
        Text do
          plain "RubyUI themes use the same CSS variable convention as "
          InlineLink(href: "https://ui.shadcn.com") { "shadcn/ui" }
          plain ". This means you can copy themes directly from "
          InlineLink(href: "https://ui.shadcn.com/themes") { "shadcn/ui themes" }
          plain " and use them in your RubyUI application."
        end
        Text do
          plain "Visit the "
          InlineLink(href: "/themes/default") { "RubyUI themes page" }
          plain " to preview and copy themes, just like you would on shadcn/ui."
        end
      end
    end
  end

  def css_variables
    space_y_2 do
      Text(size: "2", weight: "medium") { "Default background color of <body>...etc" }
      code = <<~CODE
        --background: oklch(1 0 0);
        --foreground: oklch(0.145 0 0);
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      Text(size: "2", weight: "medium") { "Muted backgrounds such as TabsList" }
      code = <<~CODE
        --muted: oklch(0.97 0 0);
        --muted-foreground: oklch(0.556 0 0);
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      Text(size: "2", weight: "medium") { "Default border color" }
      code = <<~CODE
        --border: oklch(0.922 0 0);
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      Text(size: "2", weight: "medium") { "Border color for inputs such as Input, Select or Textarea" }
      code = <<~CODE
        --input: oklch(0.922 0 0);
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      Text(size: "2", weight: "medium") { "Primary colors for Button" }
      code = <<~CODE
        --primary: oklch(0.205 0 0);
        --primary-foreground: oklch(0.985 0 0);
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      Text(size: "2", weight: "medium") { "Secondary colors for Button" }
      code = <<~CODE
        --secondary: oklch(0.97 0 0);
        --secondary-foreground: oklch(0.205 0 0);
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      Text(size: "2", weight: "medium") { "Used for accents such as hover effects on DropdownMenu::Item, Select::Item... etc" }
      code = <<~CODE
        --accent: oklch(0.97 0 0);
        --accent-foreground: oklch(0.205 0 0);
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      Text(size: "2", weight: "medium") { "Used for destructive actions such as Button.new(variant: :destructive)" }
      code = <<~CODE
        --destructive: oklch(0.577 0.245 27.325);
        --destructive-foreground: oklch(0.577 0.245 27.325);
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      Text(size: "2", weight: "medium") { "Used for focus ring" }
      code = <<~CODE
        --ring: oklch(0.708 0 0);
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      Text(size: "2", weight: "medium") { "Border radius for card, input and buttons" }
      code = <<~CODE
        --radius: 0.625rem;
      CODE
      Codeblock(code, syntax: :css)
    end
  end

  def adding_a_color
    space_y_2 do
      Text(size: "2", weight: "medium") do
        span(class: "text-muted-foreground") { "app/stylesheets/" }
        plain "application.tailwind.css"
      end
      code = <<~CODE
        :root {
          --contrast: oklch(0.75 0.18 85);
          --contrast-foreground: oklch(0.25 0.05 85);
        }

        .dark {
          --contrast: oklch(0.85 0.15 85);
          --contrast-foreground: oklch(0.2 0.05 85);
        }
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      Text(size: "2", weight: "medium") { "application.tailwind.css (inside @theme inline)" }
      code = <<~CODE
        @theme inline {
          --color-contrast: var(--contrast);
          --color-contrast-foreground: var(--contrast-foreground);
        }
      CODE
      Codeblock(code, syntax: :css)
    end

    Text do
      plain "You can now use the "
      InlineCode { "contrast" }
      plain " and "
      InlineCode { "contrast-foreground" }
      plain " variables in your application."
    end

    code = <<~CODE
      <div className="bg-contrast text-contrast-foreground">We love Ruby</div>
    CODE
    Codeblock(code, syntax: :html)
  end

  def space_y_4(&)
    div(class: "space-y-4", &)
  end

  def space_y_2(&)
    div(class: "space-y-2", &)
  end
end
