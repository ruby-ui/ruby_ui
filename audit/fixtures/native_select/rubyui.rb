# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/native_select (strings in content.yml).
  class NativeSelect < Phlex::HTML
    include RubyUI

    LABEL = "text-sm font-medium leading-none"

    def view_template
      div(class: "flex w-80 flex-col gap-6") do
        field("fruit", "Fruit") do
          NativeSelect(id: "fruit", data: {audit_select: true, audit_trigger: true}) { fruits }
        end
        field("department", "Department") do
          NativeSelect(id: "department", data: {audit_select: true}) do
            NativeSelectOption(value: "") { "Select a department" }
            NativeSelectGroup(label: "Engineering") do
              NativeSelectOption(value: "frontend") { "Frontend" }
              NativeSelectOption(value: "backend") { "Backend" }
            end
            NativeSelectGroup(label: "Sales") do
              NativeSelectOption(value: "account_executive") { "Account Executive" }
            end
          end
        end
        field("disabled", "Disabled") do
          NativeSelect(id: "disabled", disabled: true, data: {audit_select: true}) { fruits }
        end
        field("invalid", "Invalid") do
          NativeSelect(id: "invalid", aria: {invalid: "true"}, data: {audit_select: true}) { fruits }
        end
        field("small", "Small") do
          NativeSelect(id: "small", size: :sm, data: {audit_select: true}) { fruits }
        end
      end
    end

    private

    def fruits
      NativeSelectOption(value: "") { "Select a fruit" }
      NativeSelectOption(value: "apple") { "Apple" }
      NativeSelectOption(value: "banana") { "Banana" }
      NativeSelectOption(value: "blueberry") { "Blueberry" }
    end

    def field(id, text, &)
      div(class: "flex flex-col gap-2") do
        label(for: id, class: LABEL) { text }
        yield
      end
    end
  end
end
