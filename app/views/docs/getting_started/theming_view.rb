# frozen_string_literal: true

class Docs::GettingStarted::ThemingView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Theming", description: "Using CSS variables for theming.")

      div(class: "space-y-4") do
        TypographyH2 { "Introduction" }
        TypographyP do
          plain "Phlex UI uses CSS Variables like "
          TypographyInlineCode { "--primary: 0 0% 9%" }
          plain " for theming. This allows you to easily customize the look and feel of your application."
        end
        # List the 2 benefits. That we can use CSS variables to change the style, without changing the tailwindcss classes used
        # And that we can change the style of a particular tailwindcss class for both light and dark mode, without having to duplicate the tailwindcss class
        # For instance, bg-primary will work for both light and dark mode, without having to define both bg-primary and dark:bg-primary-dark (or something else like that)
        TypographyP do
          plain "There are "
          span(class: "font-medium") { "two main benefits" }
          plain " to this approach:"
        end
        TypographyList do
          TypographyListItem do
            span(class: "font-medium") { "Easily customisable design " }
            plain "by updating CSS variables, without having to update the RBUI component."
          end
          TypographyListItem do
            span(class: "font-medium") { "Simpler implementation " }
            plain " for both light and dark mode, by not having to duplicate the TailwindCSS class (e.g. "
            TypographyInlineCode { "bg-primary" }
            plain " will work for both light and dark mode, without having to define both "
            TypographyInlineCode { "bg-primary" }
            plain " and "
            TypographyInlineCode { "dark:bg-primary-dark" }
            plain " - Or something else like that)."
          end
        end
      end

      div(class: "space-y-4") do
        TypographyH2 { "Convention" }
        TypographyP do
          plain "We use a simple "
          TypographyInlineCode { "background" }
          plain " and "
          TypographyInlineCode { "foreground" }
          plain " convention for colors. The "
          TypographyInlineCode { "background" }
          plain " variable is used for the background color of the component and the "
          TypographyInlineCode { "foreground" }
          plain " variable is used for the text color. This is similar to other component libraries that are popular in React and elsewhere, and it works well in our experience."
        end
        Alert(class: "bg-transparent") do
          AlertDescription do
            plain "The "
            TypographyInlineCode { "background" }
            plain " suffix is omitted when the variable is used for the background color of the component."
          end
        end
        TypographyP { "Given the following CSS variables:" }
        code = <<~CODE
          --primary: 222.2 47.4% 11.2%;
          --primary-foreground: 210 40% 98%;
        CODE
        Codeblock(code, syntax: :css)
        TypographyP do
          plain "The "
          TypographyInlineCode { "background" }
          plain " color of the following component will be "
          TypographyInlineCode { "hsl(var(--primary))" }
          plain " and the "
          TypographyInlineCode { "foreground" }
          plain " color will be "
          TypographyInlineCode { "hsl(var(--primary-foreground))" }
          plain "."
        end
        code = <<~CODE
          <div className="bg-primary text-primary-foreground">We love Ruby</div>
        CODE
        Codeblock(code, syntax: :html)
        Alert(class: "bg-transparent") do
          AlertDescription do
            span(class: "font-medium") { "CSS variables must be defined without color space function" }
            plain ". See the "
            TypographyInlineLink(href: "https://tailwindcss.com/docs/customizing-colors#using-css-variables") { "Tailwind CSS documentation" }
            plain " for more information."
          end
        end
      end

      div(class: "space-y-4") do
        TypographyH2 { "List of variables" }
        TypographyP { "Here's the list of variables available for customization:" }
        Card(class: "space-y-4 shadow-none p-4 md:p-6") do
          css_variables
        end
      end

      div(class: "space-y-4") do
        TypographyH2 { "Adding new colors" }
        TypographyP do
          plain "To add new colors, you need to add them to your "
          TypographyInlineCode { "application.tailwind.css" }
          plain " file and to your "
          TypographyInlineCode { "tailwind.config.js" }
          plain " file."
        end
        adding_a_color
      end

      div(class: "space-y-4") do
        TypographyH2 { "Other color formats" }
        TypographyP do
          plain "It's recommended to use "
          TypographyInlineLink(href: "https://www.smashingmagazine.com/2021/07/hsl-colors-css/") { "HSL colors" }
          plain " for your application. However, you can also use other color formats such as "
          TypographyInlineCode { "rgb" }
          plain " or "
          TypographyInlineCode { "rgba" }
          plain "."
        end
        TypographyP do
          plain "See "
          TypographyInlineLink(href: "https://tailwindcss.com/docs/customizing-colors#using-css-variables") { "Tailwind CSS documentation" }
          plain " for more information on how to use "
          TypographyInlineCode { "rgb" }
          plain ", "
          TypographyInlineCode { "rgba" }
          plain " or "
          TypographyInlineCode { "hsl" }
          plain " colors."
        end
      end
    end
  end

  def css_variables
    space_y_2 do
      TypographySmall { "Default background color of <body>...etc" }
      code = <<~CODE
        --background: 0 0% 100%;
        --foreground: 222.2 47.4% 11.2%;
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      TypographySmall { "Muted backgrounds such as TabsList" }
      code = <<~CODE
        --muted: 210 40% 96.1%;
        --muted-foreground: 215.4 16.3% 46.9%;
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      TypographySmall { "Default border color" }
      code = <<~CODE
        --border: 214.3 31.8% 91.4%;
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      TypographySmall { "Border color for inputs such as Input, Select or Textarea" }
      code = <<~CODE
        --input: 214.3 31.8% 91.4%;
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      TypographySmall { "Primary colors for Button" }
      code = <<~CODE
        --primary: 222.2 47.4% 11.2%;
        --primary-foreground: 210 40% 98%;
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      TypographySmall { "Secondary colors for Button" }
      code = <<~CODE
        --secondary: 210 40% 96.1%;
        --secondary-foreground: 222.2 47.4% 11.2%;
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      TypographySmall { "Used for accents such as hover effects on DropdownMenu::Item, Select::Item... etc" }
      code = <<~CODE
        --accent: 210 40% 96.1%;
        --accent-foreground: 222.2 47.4% 11.2%;
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      TypographySmall { "Used for destructive actions such as Button.new(variant: :destructive)" }
      code = <<~CODE
        --destructive: 0 100% 50%;
        --destructive-foreground: 210 40% 98%;
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      TypographySmall { "Used for focus ring" }
      code = <<~CODE
        --ring: 215 20.2% 65.1%;
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      TypographySmall { "Border radius for card, input and buttons" }
      code = <<~CODE
        --radius: 0.5rem;
      CODE
      Codeblock(code, syntax: :css)
    end
  end

  def adding_a_color
    space_y_2 do
      TypographySmall do
        span(class: "text-muted-foreground") { "app/stylesheets/" }
        plain "application.tailwind.css"
      end
      code = <<~CODE
        :root {
          --contrast: 38 92% 50%;
          --contrast-foreground: 48 96% 89%;
        }

        .dark {
          --contrast: 48 96% 89%;
          --contrast-foreground: 38 92% 50%;
        }
      CODE
      Codeblock(code, syntax: :css)
    end

    space_y_2 do
      TypographySmall { "tailwind.config.js" }
      code = <<~CODE
        module.exports = {
          theme: {
            extend: {
              colors: {
                contrast: "hsl(var(--contrast))",
                "contrast-foreground": "hsl(var(--contrast-foreground))",
              },
            },
          },
        }
      CODE
      Codeblock(code, syntax: :javascript)
    end

    TypographyP do
      plain "You can now use the "
      TypographyInlineCode { "contrast" }
      plain " and "
      TypographyInlineCode { "contrast-foreground" }
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
