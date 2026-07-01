# frozen_string_literal: true

class Views::Docs::InputOtp < Views::Base
  def view_template
    component = "InputOtp"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Input OTP", description: "Accessible one-time-password input with keyboard navigation and paste support.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          InputOtp(length: 6, name: "otp") do
            InputOtpGroup do
              InputOtpSlot(index: 0)
              InputOtpSlot(index: 1)
              InputOtpSlot(index: 2)
              InputOtpSlot(index: 3)
              InputOtpSlot(index: 4)
              InputOtpSlot(index: 5)
            end
          end
        RUBY
      end

      Heading(level: 2) { "Composition" }

      Text { "InputOtpGroup and InputOtpSeparator compose freely — split slots into however many groups make sense, with a separator between each." }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          InputOtp(length: 6, name: "otp") do
            InputOtpGroup do
              InputOtpSlot(index: 0)
              InputOtpSlot(index: 1)
            end
            InputOtpSeparator()
            InputOtpGroup do
              InputOtpSlot(index: 2)
              InputOtpSlot(index: 3)
            end
            InputOtpSeparator()
            InputOtpGroup do
              InputOtpSlot(index: 4)
              InputOtpSlot(index: 5)
            end
          end
        RUBY
      end

      Heading(level: 2) { "Pattern" }

      Text { "Pass pattern: with a single-character regex class to define what InputOtp accepts. The default is \"[0-9]\" (digits only)." }

      render Docs::VisualCodeExample.new(title: "Alphanumeric", context: self) do
        <<~RUBY
          InputOtp(length: 6, name: "otp", pattern: "[0-9A-Za-z]") do
            InputOtpGroup do
              InputOtpSlot(index: 0)
              InputOtpSlot(index: 1)
              InputOtpSlot(index: 2)
              InputOtpSlot(index: 3)
              InputOtpSlot(index: 4)
              InputOtpSlot(index: 5)
            end
          end
        RUBY
      end

      Heading(level: 2) { "Four digits" }

      Text { "A common pattern for PIN codes — just pass a shorter length." }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          InputOtp(length: 4, name: "pin") do
            InputOtpGroup do
              InputOtpSlot(index: 0)
              InputOtpSlot(index: 1)
              InputOtpSlot(index: 2)
              InputOtpSlot(index: 3)
            end
          end
        RUBY
      end

      Heading(level: 2) { "Disabled" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          InputOtp(length: 6, name: "otp", disabled: true) do
            InputOtpGroup do
              InputOtpSlot(index: 0)
              InputOtpSlot(index: 1)
              InputOtpSlot(index: 2)
              InputOtpSlot(index: 3)
              InputOtpSlot(index: 4)
              InputOtpSlot(index: 5)
            end
          end
        RUBY
      end

      Heading(level: 2) { "Invalid" }

      Text { "Pass aria_invalid: \"true\" to each InputOtpSlot to show an error state." }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          InputOtp(length: 6, name: "otp") do
            InputOtpGroup do
              InputOtpSlot(index: 0, aria_invalid: "true")
              InputOtpSlot(index: 1, aria_invalid: "true")
              InputOtpSlot(index: 2, aria_invalid: "true")
              InputOtpSlot(index: 3, aria_invalid: "true")
              InputOtpSlot(index: 4, aria_invalid: "true")
              InputOtpSlot(index: 5, aria_invalid: "true")
            end
          end
        RUBY
      end

      Heading(level: 2) { "Form" }

      Text { "A full example combining InputOtp with Card, Button, and InlineLink — bigger slots via class:, a resend action, and fallback links." }

      render Docs::VisualCodeExample.new(title: "Verify your login", context: self) do
        <<~RUBY
          Card(class: "mx-auto max-w-md") do
            CardHeader do
              CardTitle { "Verify your login" }
              CardDescription do
                plain "Enter the verification code we sent to your email address: "
                span(class: "font-medium") { "m@example.com" }
                plain "."
              end
            end
            CardContent(class: "space-y-4") do
              div(class: "flex items-center justify-between") do
                label(class: "text-sm font-medium") { "Verification code" }
                Button(variant: :outline, size: :sm) do
                  svg(
                    xmlns: "http://www.w3.org/2000/svg",
                    viewbox: "0 0 24 24",
                    fill: "none",
                    stroke: "currentColor",
                    stroke_width: "2",
                    stroke_linecap: "round",
                    stroke_linejoin: "round",
                    class: "w-4 h-4 mr-2"
                  ) do |s|
                    s.path(d: "M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8")
                    s.path(d: "M21 3v5h-5")
                    s.path(d: "M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16")
                    s.path(d: "M8 16H3v5")
                  end
                  plain "Resend Code"
                end
              end
              InputOtp(length: 6, name: "otp", required: true) do
                InputOtpGroup do
                  InputOtpSlot(index: 0, class: "h-12 w-11 text-xl")
                  InputOtpSlot(index: 1, class: "h-12 w-11 text-xl")
                  InputOtpSlot(index: 2, class: "h-12 w-11 text-xl")
                end
                InputOtpSeparator(class: "mx-2")
                InputOtpGroup do
                  InputOtpSlot(index: 3, class: "h-12 w-11 text-xl")
                  InputOtpSlot(index: 4, class: "h-12 w-11 text-xl")
                  InputOtpSlot(index: 5, class: "h-12 w-11 text-xl")
                end
              end
              InlineLink(href: "#") { "I no longer have access to this email address." }
            end
            CardFooter(class: "flex flex-col items-stretch gap-2") do
              Button(class: "w-full") { "Verify" }
              Text(size: "sm", weight: "muted") do
                plain "Having trouble signing in? "
                InlineLink(href: "#") { "Contact support" }
              end
            end
          end
        RUBY
      end

      Heading(level: 2) { "Reacting to completion" }

      Text { "The controller dispatches a ruby-ui--input-otp:complete custom event (detail: { value }) once the value reaches length characters, and a ruby-ui--input-otp:input event on every change. Wire a Stimulus action on a parent element to react — for example, to auto-submit a form:" }

      Codeblock(<<~JS, syntax: :javascript)
        // app/javascript/controllers/otp_form_controller.js
        import { Controller } from "@hotwired/stimulus"

        export default class extends Controller {
          submit() {
            this.element.requestSubmit()
          }
        }
      JS

      Codeblock(<<~HTML, syntax: :html)
        <form data-controller="otp-form" data-action="ruby-ui--input-otp:complete->otp-form#submit">
          <!-- InputOtp(...) here -->
        </form>
      HTML

      render Components::ComponentSetup::Tabs.new(component_name: component)

      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
