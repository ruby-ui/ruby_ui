# frozen_string_literal: true

class Docs::TailwindCss < ApplicationComponent
  def view_template
    TypographyLarge { "Add CSS variables" }
    TypographyP do
      plain "Add the following to your "
      TypographyInlineCode { "app/assets/stylesheets/application.tailwind.css" }
      plain " file"
    end
    code = css_variables
    Codeblock(code, syntax: :css)
  end

  private

  def css_variables
    <<~CODE
      @tailwind base;
      @tailwind components;
      @tailwind utilities;


      @layer base {
        :root {
          --background: 0 0% 100%;
          --foreground: 240 10% 3.9%;
          --card: 0 0% 100%;
          --card-foreground: 240 10% 3.9%;
          --popover: 0 0% 100%;
          --popover-foreground: 240 10% 3.9%;
          --primary: 240 5.9% 10%;
          --primary-foreground: 0 0% 98%;
          --secondary: 240 4.8% 95.9%;
          --secondary-foreground: 240 5.9% 10%;
          --muted: 240 4.8% 95.9%;
          --muted-foreground: 240 3.8% 46.1%;
          --accent: 240 4.8% 95.9%;
          --accent-foreground: 240 5.9% 10%;
          --destructive: 0 84.2% 60.2%;
          --destructive-foreground: 0 0% 98%;
          --border: 240 5.9% 90%;
          --input: 240 5.9% 90%;
          --ring: 240 5.9% 10%;
          --radius: 0.5rem;
          --warning: 38 92% 50%;
          --warning-foreground: 0 0% 100%;
          --success: 87 100% 37%;
          --success-foreground: 0 0% 100%;
        }
      
        .dark {
          --background: 240 10% 3.9%;
          --foreground: 0 0% 98%;
          --card: 240 10% 3.9%;
          --card-foreground: 0 0% 98%;
          --popover: 240 10% 3.9%;
          --popover-foreground: 0 0% 98%;
          --primary: 0 0% 98%;
          --primary-foreground: 240 5.9% 10%;
          --secondary: 240 3.7% 15.9%;
          --secondary-foreground: 0 0% 98%;
          --muted: 240 3.7% 15.9%;
          --muted-foreground: 240 5% 64.9%;
          --accent: 240 3.7% 15.9%;
          --accent-foreground: 0 0% 98%;
          --destructive: 0 62.8% 30.6%;
          --destructive-foreground: 0 0% 98%;
          --border: 240 3.7% 15.9%;
          --input: 240 3.7% 15.9%;
          --ring: 240 4.9% 83.9%;
          --warning: 38 92% 50%;
          --warning-foreground: 0 0% 100%;
          --success: 84 81% 44%;
          --success-foreground: 0 0% 100%;
        }
      }

      @layer base {
        * {
          @apply border-border;
        }
        body {
          @apply bg-background text-foreground;
          font-feature-settings: "rlig" 1, "calt" 1;
        }
      }
    CODE
  end
end
