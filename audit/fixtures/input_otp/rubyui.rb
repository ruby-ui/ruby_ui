# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/input_otp (strings in content.yml).
  class InputOtp < Phlex::HTML
    include RubyUI

    LABEL = "text-sm font-medium leading-none"

    def view_template
      div(class: "flex flex-col gap-6") do
        field("simple", "Simple") do
          InputOtp(id: "simple", length: 6, data: {audit_trigger: true}) do
            InputOtpGroup { 3.times { |i| InputOtpSlot(index: i) } }
            InputOtpSeparator()
            InputOtpGroup { 3.upto(5) { |i| InputOtpSlot(index: i) } }
          end
        end
        field("filled", "With Separator") { pairs(id: "filled", value: "123456") }
        field("disabled", "Disabled") do
          InputOtp(id: "disabled", length: 6, disabled: true, value: "123456") do
            InputOtpGroup { 3.times { |i| InputOtpSlot(index: i) } }
            InputOtpSeparator()
            InputOtpGroup { 3.upto(5) { |i| InputOtpSlot(index: i) } }
          end
        end
        field("invalid", "Invalid State") { pairs(id: "invalid", value: "000000", invalid: true) }
      end
    end

    private

    def pairs(id:, value:, invalid: false)
      slot_attrs = invalid ? {aria: {invalid: "true"}} : {}
      InputOtp(id: id, length: 6, value: value) do
        [[0, 1], [2, 3], [4, 5]].each_with_index do |pair, n|
          InputOtpSeparator() if n.positive?
          InputOtpGroup { pair.each { |i| InputOtpSlot(index: i, **slot_attrs) } }
        end
      end
    end

    def field(id, text, &)
      div(class: "flex flex-col gap-2") do
        label(for: id, class: LABEL) { text }
        yield
      end
    end
  end
end
