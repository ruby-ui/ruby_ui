# frozen_string_literal: true

class Docs::TabsView < ApplicationView
  def template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-8") do
      div(class: 'space-y-2') do
        render Typography::H1.new { "Tabs" }
        render Typography::P.new { "A set of layered sections of content—known as tab panels—that are displayed one at a time." }
      end

      render Docs::VisualCodeExample.new(title: "Default") do
        render Tabs.new(default_value: "account", class: 'w-96') do
          render TabsList.new do
            render TabsTrigger.new(value: "account") { "Account" }
            render TabsTrigger.new(value: "profile") { "Profile" }
          end
          render TabsContent.new(value: "account") do
            div(class: "rounded-lg border p-4 bg-background text-foreground") { "Account" }
          end
          render TabsContent.new(value: "profile") do
            div(class: "rounded-lg border p-4 bg-background text-foreground") { "Profile" }
          end
        end
      end

      render Docs::VisualCodeExample.new(title: "Full width") do
        render Tabs.new(default_value: "account", class: 'w-96') do
          render TabsList.new(class: 'w-full grid grid-cols-2') do
            render TabsTrigger.new(value: "account") { "Account" }
            render TabsTrigger.new(value: "profile") { "Profile" }
          end
          render TabsContent.new(value: "account") do
            div(class: "rounded-lg border p-4 bg-background text-foreground") { "Account" }
          end
          render TabsContent.new(value: "profile") do
            div(class: "rounded-lg border p-4 bg-background text-foreground") { "Profile" }
          end
        end
      end

      render Docs::InstallationInstructionsComingSoon.new
    end
  end
end
