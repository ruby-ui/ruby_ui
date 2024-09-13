# frozen_string_literal: true

module Rbui
  class TabsPreview < Lookbook::Preview
    # Default TabsPreview
    # ---------------
    def default
      render(TestView.new) do
        Tabs(default_value: "account", class: "w-96") do
          TabsList do
            TabsTrigger(value: "account") { "Account" }
            TabsTrigger(value: "password") { "Password" }
          end

          TabsContent(value: "account") do
            div(class: "rounded-lg border p-6 space-y-4 bg-background text-foreground") do
              div(class: "space-y-0") do
                plain("Account")
                plain("Update your account details.")
              end
            end
          end

          TabsContent(value: "password") do
            div(class: "rounded-lg border p-6 space-y-4 bg-background text-foreground") do
              div do
                plain("Password")
                plain("Change your password here. After saving, you'll be logged out.")
              end
            end
          end
        end
      end
    end
  end
end
