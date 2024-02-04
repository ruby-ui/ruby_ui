# frozen_string_literal: true

class Docs::GettingStarted::ThemingView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Theming", description: "Using CSS variables for theming.")

      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new { "Introduction" }
        render PhlexUI::Typography::P.new do
          plain "Phlex UI uses CSS Variables like "
          render PhlexUI::Typography::InlineCode.new { "--primary: 0 0% 9%" }
          plain " for theming. This allows you to easily customize the look and feel of your application."
        end
        # List the 2 benefits. That we can use CSS variables to change the style, without changing the tailwindcss classes used
        # And that we can change the style of a particular tailwindcss class for both light and dark mode, without having to duplicate the tailwindcss class
        # For instance, bg-primary will work for both light and dark mode, without having to define both bg-primary and dark:bg-primary-dark (or something else like that)
        render PhlexUI::Typography::P.new do
          plain "There are "
          span(class: "font-medium") { "two main benefits" }
          plain " to this approach:"
        end
        render PhlexUI::Typography::List.new do
          render PhlexUI::Typography::ListItem.new do
            span(class: "font-medium") { "Easily customisable design " }
            plain "by updating CSS variables, without having to update the PhlexUI component."
          end
          render PhlexUI::Typography::ListItem.new do
            span(class: "font-medium") { "Simpler implementation " }
            plain " for both light and dark mode, by not having to duplicate the TailwindCSS class (e.g. "
            render PhlexUI::Typography::InlineCode.new { "bg-primary" }
            plain " will work for both light and dark mode, without having to define both "
            render PhlexUI::Typography::InlineCode.new { "bg-primary" }
            plain " and "
            render PhlexUI::Typography::InlineCode.new { "dark:bg-primary-dark" }
            plain " - Or something else like that)."
          end
        end
      end
      
      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new { "Convention" }
        render PhlexUI::Typography::P.new do
          plain "We use a simple "
          render PhlexUI::Typography::InlineCode.new { "background" }
          plain " and "
          render PhlexUI::Typography::InlineCode.new { "foreground" }
          plain " convention for colors. The "
          render PhlexUI::Typography::InlineCode.new { "background" }
          plain " variable is used for the background color of the component and the "
          render PhlexUI::Typography::InlineCode.new { "foreground" }
          plain " variable is used for the text color. This is similar to other component libraries that are popular in React and elsewhere, and it works well in our experience."
        end
        render PhlexUI::Alert.new(class: 'bg-transparent') do
          render PhlexUI::Alert::Description.new do
            plain "The "
            render PhlexUI::Typography::InlineCode.new { "background" }
            plain " suffix is omitted when the variable is used for the background color of the component."
          end
        end
        render PhlexUI::Typography::P.new { "Given the following CSS variables:" }
        code = <<~CODE
            --primary: 222.2 47.4% 11.2%;
            --primary-foreground: 210 40% 98%;
          CODE
        render PhlexUI::Codeblock.new(code, syntax: :css)
        render PhlexUI::Typography::P.new do 
          plain "The "
          render PhlexUI::Typography::InlineCode.new { "background" }
          plain " color of the following component will be "
          render PhlexUI::Typography::InlineCode.new { "hsl(var(--primary))" }
          plain " and the "
          render PhlexUI::Typography::InlineCode.new { "foreground" }
          plain " color will be "
          render PhlexUI::Typography::InlineCode.new { "hsl(var(--primary-foreground))" }
          plain "."
        end
        code = <<~CODE
            <div className="bg-primary text-primary-foreground">We love Ruby</div>
          CODE
        render PhlexUI::Codeblock.new(code, syntax: :html)
        render PhlexUI::Alert.new(class: 'bg-transparent') do
          render PhlexUI::Alert::Description.new do
            span(class: "font-medium") { "CSS variables must be defined without color space function" }
            plain ". See the "
            render Typography::InlineLink.new(href: "https://tailwindcss.com/docs/customizing-colors#using-css-variables") { "Tailwind CSS documentation" }
            plain " for more information."
          end
        end
      end

      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new { "List of variables" }
        render PhlexUI::Typography::P.new { "Here's the list of variables available for customization:" }
        render PhlexUI::Card.new(class: "space-y-4 shadow-none p-4 md:p-6") do
          css_variables
        end
      end

      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new { "Adding new colors" }
        render PhlexUI::Typography::P.new do
          plain "To add new colors, you need to add them to your "
          render PhlexUI::Typography::InlineCode.new { "application.tailwind.css" }
          plain " file and to your "
          render PhlexUI::Typography::InlineCode.new { "tailwind.config.js" }
          plain " file."
        end
        adding_a_color
      end

      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new { "Other color formats" }
        render PhlexUI::Typography::P.new do
          plain "It's recommended to use "
          render Typography::InlineLink.new(href: "https://www.smashingmagazine.com/2021/07/hsl-colors-css/") { "HSL colors" }
          plain " for your application. However, you can also use other color formats such as "
          render PhlexUI::Typography::InlineCode.new { "rgb" }
          plain " or "
          render PhlexUI::Typography::InlineCode.new { "rgba" }
          plain "."
        end
        render PhlexUI::Typography::P.new do
          plain "See "
          render Typography::InlineLink.new(href: "https://tailwindcss.com/docs/customizing-colors#using-css-variables") { "Tailwind CSS documentation" }
          plain " for more information on how to use "
          render PhlexUI::Typography::InlineCode.new { "rgb" }
          plain ", "
          render PhlexUI::Typography::InlineCode.new { "rgba" }
          plain " or "
          render PhlexUI::Typography::InlineCode.new { "hsl" }
          plain " colors."
        end
      end
    end
  end

  def css_variables
    space_y_2 do
      render PhlexUI::Typography::Small.new { "Default background color of <body>...etc" }
      code = <<~CODE
          --background: 0 0% 100%;
          --foreground: 222.2 47.4% 11.2%;
        CODE
      render PhlexUI::Codeblock.new(code, syntax: :css)
    end

    space_y_2 do
      render PhlexUI::Typography::Small.new { "Muted backgrounds such as PhlexUI::Tabs::List" }
      code = <<~CODE
          --muted: 210 40% 96.1%;
          --muted-foreground: 215.4 16.3% 46.9%;
        CODE
      render PhlexUI::Codeblock.new(code, syntax: :css)
    end

    space_y_2 do
      render PhlexUI::Typography::Small.new { "Default border color" }
      code = <<~CODE
          --border: 214.3 31.8% 91.4%;
        CODE
      render PhlexUI::Codeblock.new(code, syntax: :css)
    end

    space_y_2 do
      render PhlexUI::Typography::Small.new { "Border color for inputs such as PhlexUI::Input, PhlexUI::Select or PhlexUI::Textarea" }
      code = <<~CODE
          --input: 214.3 31.8% 91.4%;
        CODE
      render PhlexUI::Codeblock.new(code, syntax: :css)
    end

    space_y_2 do
      render PhlexUI::Typography::Small.new { "Primary colors for PhlexUI::Button" }
      code = <<~CODE
          --primary: 222.2 47.4% 11.2%;
          --primary-foreground: 210 40% 98%;
        CODE
      render PhlexUI::Codeblock.new(code, syntax: :css)
    end

    space_y_2 do
      render PhlexUI::Typography::Small.new { "Secondary colors for PhlexUI::Button" }
      code = <<~CODE
          --secondary: 210 40% 96.1%;
          --secondary-foreground: 222.2 47.4% 11.2%;
        CODE
      render PhlexUI::Codeblock.new(code, syntax: :css)
    end

    space_y_2 do
      render PhlexUI::Typography::Small.new { "Used for accents such as hover effects on PhlexUI::DropdownMenu::Item, PhlexUI::Select::Item... etc" }
      code = <<~CODE
          --accent: 210 40% 96.1%;
          --accent-foreground: 222.2 47.4% 11.2%;
        CODE
      render PhlexUI::Codeblock.new(code, syntax: :css)
    end

    space_y_2 do
      render PhlexUI::Typography::Small.new { "Used for destructive actions such as PhlexUI::Button.new(variant: :destructive)" }
      code = <<~CODE
          --destructive: 0 100% 50%;
          --destructive-foreground: 210 40% 98%;
        CODE
      render PhlexUI::Codeblock.new(code, syntax: :css)
    end

    space_y_2 do
      render PhlexUI::Typography::Small.new { "Used for focus ring" }
      code = <<~CODE
          --ring: 215 20.2% 65.1%;
        CODE
      render PhlexUI::Codeblock.new(code, syntax: :css)
    end

    space_y_2 do
      render PhlexUI::Typography::Small.new { "Border radius for card, input and buttons" }
      code = <<~CODE
          --radius: 0.5rem;
        CODE
      render PhlexUI::Codeblock.new(code, syntax: :css)
    end
  end

  def adding_a_color
    space_y_2 do
      render PhlexUI::Typography::Small.new do
        span(class: 'text-muted-foreground') { "app/stylesheets/" }
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
      render PhlexUI::Codeblock.new(code, syntax: :css)
    end

    space_y_2 do
      render PhlexUI::Typography::Small.new { "tailwind.config.js" }
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
      render PhlexUI::Codeblock.new(code, syntax: :javascript)
    end

    render PhlexUI::Typography::P.new do
      plain "You can now use the "
      render PhlexUI::Typography::InlineCode.new { "contrast" }
      plain " and "
      render PhlexUI::Typography::InlineCode.new { "contrast-foreground" }
      plain " variables in your application."
    end

    code = <<~CODE
        <div className="bg-contrast text-contrast-foreground">We love Ruby</div>
      CODE
    render PhlexUI::Codeblock.new(code, syntax: :html)
  end

  def space_y_4(&block)
    div(class: "space-y-4", &block)
  end

  def space_y_2(&block)
    div(class: "space-y-2", &block)
  end
end
