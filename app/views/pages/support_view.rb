# frozen_string_literal: true

class Pages::SupportView < ApplicationView
  PHLEX_REPORT_BUG_URL = "https://github.com/PhlexUI/phlexui_issues/issues/new?assignees=&labels=bug&template=bug_report.md&title="

  def template
    render Shared::GridPattern.new
    div(class: 'container max-w-2xl mx-auto px-4 pb-24 space-y-6') do
      div(class: "space-y-4 py-16 md:py-24 md:pb-20 max-w-lg mx-auto") do
        render PhlexUI::Typography::H1.new(class: 'text-center') { "Support" }
        render PhlexUI::Typography::Lead.new(class: 'text-center') { "Have a question about PhlexUI or an issue with your purchase? Get in touch and we'll help you out." }
      end
      sales_support
      bug_reports
      technical_support
    end
  end

  private

  def sales_support
    card do
      div(class: 'flex items-center gap-x-2') do
        support_icon
        render PhlexUI::Typography::Large.new { "Sales support" }
      end
      render PhlexUI::Typography::P.new(class: 'text-muted-foreground') do
        plain "If you need help with something related to your purchase (didn't get your receipt, entered the wrong email at purchase, need a refund, etc.) please "
        render PhlexUI::Link.new(href: "mailto:#{ENV['SUPPORT_EMAIL']}", class: '!px-1 !inline !h-auto') { "email us" }
        plain " and we will do everything we can to take care of you."
      end
      render PhlexUI::Link.new(href: "mailto:#{ENV['SUPPORT_EMAIL']}", variant: :outline) do
        plain "Get in touch"
        arrow_right
      end
    end
  end

  def bug_reports
    card do
      div(class: 'flex items-center gap-x-2') do
        bug_icon
        render PhlexUI::Typography::Large.new { "Bug reports" }
      end
      render PhlexUI::Typography::P.new(class: 'text-muted-foreground') do
        plain "If you find a bug with a component that you'd like to report for us to fix, please"
        render PhlexUI::Link.new(href: PHLEX_REPORT_BUG_URL, target: :_blank, class: '!px-1 !inline !h-auto') { "open an issue" }
        plain "on GitHub."
      end
      render PhlexUI::Link.new(variant: :outline, href: PHLEX_REPORT_BUG_URL, target: :_blank) do
        plain "Report bug"
        arrow_right
      end
    end
  end

  def technical_support
    card do
      div(class: 'flex items-center gap-x-2') do
        chat_icon
        render PhlexUI::Typography::Large.new { "Technical support" }
      end
      render PhlexUI::Typography::P.new(class: 'text-muted-foreground') { "If you have questions about things like integrating a component into your project, tweaking a design in a particular way, accomplishing some interactive behavior with JavaScript, etc., we recommend joining the PhlexUI Discord community and asking your question to the group." }
      render PhlexUI::Link.new(variant: :outline, href: ENV['DISCORD_INVITE_LINK']) do
        plain "Join the PhlexUI Discord Community"
        arrow_right
      end
    end
  end

  def card(&block)
    div(class: 'p-8 relative overflow-hidden space-y-4 border rounded-2xl bg-background', &block)
  end

  def arrow_right
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "2",
      stroke: "currentColor",
      class: "w-4 h-4 ml-2 -mr-1"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d: "M4.5 12h15m0 0l-6.75-6.75M19.5 12l-6.75 6.75"
      )
    end
  end

  def support_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-8 h-8 text-lime-500"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M16.712 4.33a9.027 9.027 0 011.652 1.306c.51.51.944 1.064 1.306 1.652M16.712 4.33l-3.448 4.138m3.448-4.138a9.014 9.014 0 00-9.424 0M19.67 7.288l-4.138 3.448m4.138-3.448a9.014 9.014 0 010 9.424m-4.138-5.976a3.736 3.736 0 00-.88-1.388 3.737 3.737 0 00-1.388-.88m2.268 2.268a3.765 3.765 0 010 2.528m-2.268-4.796a3.765 3.765 0 00-2.528 0m4.796 4.796c-.181.506-.475.982-.88 1.388a3.736 3.736 0 01-1.388.88m2.268-2.268l4.138 3.448m0 0a9.027 9.027 0 01-1.306 1.652c-.51.51-1.064.944-1.652 1.306m0 0l-3.448-4.138m3.448 4.138a9.014 9.014 0 01-9.424 0m5.976-4.138a3.765 3.765 0 01-2.528 0m0 0a3.736 3.736 0 01-1.388-.88 3.737 3.737 0 01-.88-1.388m2.268 2.268L7.288 19.67m0 0a9.024 9.024 0 01-1.652-1.306 9.027 9.027 0 01-1.306-1.652m0 0l4.138-3.448M4.33 16.712a9.014 9.014 0 010-9.424m4.138 5.976a3.765 3.765 0 010-2.528m0 0c.181-.506.475-.982.88-1.388a3.736 3.736 0 011.388-.88m-2.268 2.268L4.33 7.288m6.406 1.18L7.288 4.33m0 0a9.024 9.024 0 00-1.652 1.306A9.025 9.025 0 004.33 7.288"
      )
    end
  end

  def bug_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-8 h-8 text-amber-500"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M12 12.75c1.148 0 2.278.08 3.383.237 1.037.146 1.866.966 1.866 2.013 0 3.728-2.35 6.75-5.25 6.75S6.75 18.728 6.75 15c0-1.046.83-1.867 1.866-2.013A24.204 24.204 0 0112 12.75zm0 0c2.883 0 5.647.508 8.207 1.44a23.91 23.91 0 01-1.152 6.06M12 12.75c-2.883 0-5.647.508-8.208 1.44.125 2.104.52 4.136 1.153 6.06M12 12.75a2.25 2.25 0 002.248-2.354M12 12.75a2.25 2.25 0 01-2.248-2.354M12 8.25c.995 0 1.971-.08 2.922-.236.403-.066.74-.358.795-.762a3.778 3.778 0 00-.399-2.25M12 8.25c-.995 0-1.97-.08-2.922-.236-.402-.066-.74-.358-.795-.762a3.734 3.734 0 01.4-2.253M12 8.25a2.25 2.25 0 00-2.248 2.146M12 8.25a2.25 2.25 0 012.248 2.146M8.683 5a6.032 6.032 0 01-1.155-1.002c.07-.63.27-1.222.574-1.747m.581 2.749A3.75 3.75 0 0115.318 5m0 0c.427-.283.815-.62 1.155-.999a4.471 4.471 0 00-.575-1.752M4.921 6a24.048 24.048 0 00-.392 3.314c1.668.546 3.416.914 5.223 1.082M19.08 6c.205 1.08.337 2.187.392 3.314a23.882 23.882 0 01-5.223 1.082"
      )
    end
  end

  def chat_icon
    svg(
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewbox: "0 0 24 24",
      stroke_width: "1.5",
      stroke: "currentColor",
      class: "w-8 h-8 text-sky-500"
    ) do |s|
      s.path(
        stroke_linecap: "round",
        stroke_linejoin: "round",
        d:
          "M7.5 8.25h9m-9 3H12m-9.75 1.51c0 1.6 1.123 2.994 2.707 3.227 1.129.166 2.27.293 3.423.379.35.026.67.21.865.501L12 21l2.755-4.133a1.14 1.14 0 01.865-.501 48.172 48.172 0 003.423-.379c1.584-.233 2.707-1.626 2.707-3.228V6.741c0-1.602-1.123-2.995-2.707-3.228A48.394 48.394 0 0012 3c-2.392 0-4.744.175-7.043.513C3.373 3.746 2.25 5.14 2.25 6.741v6.018z"
      )
    end
  end
end
