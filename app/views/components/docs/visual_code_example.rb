# frozen_string_literal: true

class Docs::VisualCodeExample < ApplicationComponent
  def initialize(title: nil, description: nil, context: nil, premium: false)
    @title = title
    @description = description
    @premium = premium
    @context = context
  end

  # standard:disable Style/ArgumentsForwarding
  def view_template(&block)
    @display_code = CGI.unescapeHTML(capture(&block))

    div(id: @title) do
      div(class: "relative") do
        render PhlexUI::Tabs.new(default_value: "preview") do
          div(class: "flex justify-between items-end mb-4 gap-x-2") do
            render_header
            div(class: "flex-grow") # Spacer
            render_tab_triggers
          end
          render_tab_contents(&block)
        end
      end
    end
  end
  # standard:enable Style/ArgumentsForwarding

  private

  def render_header
    div do
      if @title
        div(class: "flex items-center gap-x-2 mb-1") do
          render PhlexUI::Typography::H4.new { @title.capitalize }
        end
      end
      p { @description } if @description
    end
  end

  def render_tab_triggers
    render PhlexUI::Tabs::List.new do
      render_tab_trigger("preview", "Preview", method(:eye_icon))
      render_tab_trigger("code", "Code", method(:code_icon))
    end
  end

  def render_tab_trigger(value, label, icon_method)
    render PhlexUI::Tabs::Trigger.new(value: value) do
      icon_method.call
      span { label }
    end
  end

  def render_tab_contents(&block)
    render PhlexUI::Tabs::Content.new(value: "preview") { render_preview_tab(&block) }
    render PhlexUI::Tabs::Content.new(value: "code") { render_code_tab }
  end

  def render_preview_tab(&block)
    div(class: "mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 relative rounded-md border") do
      div(class: "preview flex min-h-[350px] w-full justify-center p-10 items-center") do
        decoded_code = CGI.unescapeHTML(@display_code)
        @context.instance_eval(decoded_code)
      end
    end
  end

  def render_code_tab
    div(class: "mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 relative rounded-md border") do
      render PhlexUI::Codeblock.new(@display_code, syntax: :ruby, class: "-m-px")
    end
  end

  def eye_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-4 h-4 mr-2"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178z"
      )
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d: "M15 12a3 3 0 11-6 0 3 3 0 016 0z"
      )
    end
  end

  def code_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-4 h-4 mr-2"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d: "M17.25 6.75L22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3l-4.5 16.5"
      )
    end
  end
end

# # frozen_string_literal: true

# class Docs::VisualCodeExample < ApplicationComponent
#     def initialize(title: nil, description: nil, context: nil)
#         @title = title
#         @description = description
#         @context = context
#     end

#     def view_template(&block)
#         @display_code = capture(&block)

#         div(id: @title) do
#             render_header if @title || @description
#             render_tabs(&block)
#         end
#     end

#     private

#     def render_header
#         div(class: 'space-y-1 mb-4') do
#             render PhlexUI::Typography::H4.new { @title } if @title
#             render PhlexUI::Typography::P.new { @description } if @description
#         end
#     end

#     def render_tabs(&block)
#         render PhlexUI::Tabs.new(default_value: "preview") do
#             render_tab_triggers
#             render_tab_contents(&block)
#         end
#     end

#     def render_tab_triggers
#         render PhlexUI::Tabs::List.new do
#             render_tab_trigger("preview", "Preview", method(:eye_icon))
#             render_tab_trigger("code", "Code", method(:code_icon))
#         end
#     end

#     def render_tab_trigger(value, label, icon_method)
#         render PhlexUI::Tabs::Trigger.new(value: value) do
#             icon_method.call
#             span { label }
#         end
#     end

#     def render_tab_contents(&block)
#         render PhlexUI::Tabs::Content.new(value: "preview") { render_preview_tab(&block) }
#         render PhlexUI::Tabs::Content.new(value: "code") { render_code_tab }
#     end

#     def render_preview_tab(&block)
#         div(class: 'mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 relative rounded-md border') do
#             div(class: 'preview flex min-h-[350px] w-full justify-center p-10 items-center') do
#                 decoded_code = CGI.unescapeHTML(@display_code)
#                 @context.instance_eval(decoded_code)
#             end
#         end
#     end

#     def render_code_tab
#         div(class: 'mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 relative rounded-md border') do
#             render Codeblock.new { @display_code }
#         end
#     end

#     def eye_icon
#         svg(
#             xmlns: "http://www.w3.org/2000/svg",
#             fill: "none",
#             viewbox: "0 0 24 24",
#             stroke_width: "1.5",
#             stroke: "currentColor",
#             class: "w-4 h-4 mr-2"
#             ) do |s|
#             s.path(
#                 stroke_linecap: "round",
#                 stroke_linejoin: "round",
#                 d:
#                 "M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178z"
#             )
#             s.path(
#                 stroke_linecap: "round",
#                 stroke_linejoin: "round",
#                 d: "M15 12a3 3 0 11-6 0 3 3 0 016 0z"
#             )
#         end
#     end

#     def code_icon
#         svg(
#             xmlns: "http://www.w3.org/2000/svg",
#             fill: "none",
#             viewbox: "0 0 24 24",
#             stroke_width: "1.5",
#             stroke: "currentColor",
#             class: "w-4 h-4 mr-2"
#             ) do |s|
#             s.path(
#                 stroke_linecap: "round",
#                 stroke_linejoin: "round",
#                 d: "M17.25 6.75L22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3l-4.5 16.5"
#             )
#         end
#     end
# end
