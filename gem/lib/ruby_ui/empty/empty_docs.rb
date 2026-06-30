# frozen_string_literal: true

class Views::Docs::Empty < Views::Base
  def view_template
    component = "Empty"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Empty", description: "Use the empty component to display a state when there is no data or content.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "Default", context: self) do
        <<~RUBY
          Empty do
            EmptyHeader do
              EmptyMedia(variant: :icon) do
                svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewbox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor", class: "size-6") do |s|
                  s.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M20.25 8.511c.884.284 1.5 1.128 1.5 2.097v4.286c0 1.136-.847 2.1-1.98 2.193-.34.027-.68.052-1.02.072v3.091l-3-3c-1.354 0-2.694-.055-4.02-.163a2.115 2.115 0 0 1-.825-.242m9.345-8.334a2.126 2.126 0 0 0-.476-.095 48.64 48.64 0 0 0-8.048 0c-1.131.094-1.976 1.057-1.976 2.192v4.286c0 .837.46 1.58 1.155 1.951m9.345-8.334V6.637c0-1.621-1.152-3.026-2.76-3.235A48.455 48.455 0 0 0 11.25 3c-2.115 0-4.198.137-6.24.402-1.608.209-2.76 1.614-2.76 3.235v6.226c0 1.621 1.152 3.026 2.76 3.235.577.075 1.157.14 1.74.194V21l4.155-4.155")
                end
              end
              EmptyTitle { "No messages yet" }
              EmptyDescription { "Start a conversation to see your messages here." }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "With action", context: self) do
        <<~RUBY
          Empty do
            EmptyHeader do
              EmptyMedia(variant: :icon) do
                svg(xmlns: "http://www.w3.org/2000/svg", fill: "none", viewbox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor", class: "size-6") do |s|
                  s.path(stroke_linecap: "round", stroke_linejoin: "round", d: "M2.25 12.76c0 1.6 1.123 2.994 2.707 3.227 1.129.166 2.27.293 3.423.379.35.026.67.21.865.501L12 21l2.755-4.133a1.14 1.14 0 0 1 .865-.501 48.172 48.172 0 0 0 3.423-.379c1.584-.233 2.707-1.626 2.707-3.228V6.741c0-1.602-1.123-2.995-2.707-3.228A48.394 48.394 0 0 0 12 3c-2.392 0-4.744.175-7.043.513C3.373 3.746 2.25 5.14 2.25 6.741v6.018Z")
                end
              end
              EmptyTitle { "No projects" }
              EmptyDescription { "Get started by creating your first project." }
            end
            EmptyContent do
              Button { "Create project" }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Default media", context: self) do
        <<~RUBY
          Empty(class: "border-none") do
            EmptyHeader do
              EmptyMedia(variant: :default) do
                Avatar(size: :lg) do
                  AvatarFallback { "RU" }
                end
              end
              EmptyTitle { "No team members" }
              EmptyDescription { "Invite your team to start collaborating." }
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      # components
      render Docs::ComponentsTable.new(component_files(component))
    end
  end
end
