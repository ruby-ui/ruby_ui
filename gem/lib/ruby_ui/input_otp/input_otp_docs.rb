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

      Heading(level: 2) { "Grouped with separator" }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
        <<~RUBY
          InputOtp(length: 6, name: "otp") do
            InputOtpGroup do
              InputOtpSlot(index: 0)
              InputOtpSlot(index: 1)
              InputOtpSlot(index: 2)
            end
            InputOtpSeparator()
            InputOtpGroup do
              InputOtpSlot(index: 3)
              InputOtpSlot(index: 4)
              InputOtpSlot(index: 5)
            end
          end
        RUBY
      end

      Heading(level: 2) { "Custom pattern" }

      Text { "Pass pattern: with a single-character regex class (default is \"[0-9]\") to accept other characters, e.g. letters and digits." }

      render Docs::VisualCodeExample.new(title: "Example", context: self) do
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
