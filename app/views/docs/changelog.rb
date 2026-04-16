# frozen_string_literal: true

require "rss"
require "net/http"

class Views::Docs::Changelog < Views::Base
  def view_template
    div(class: "mx-auto max-w-[800px] py-10") do
      h1(class: "scroll-m-24 text-3xl font-semibold tracking-tight sm:text-3xl mb-4") { "Changelog" }
      p(class: "text-xl text-foreground mb-8") { "Latest updates and announcements from the RubyUI team." }

      if releases.any?
        div(class: "space-y-12") do
          releases.each do |release|
            div(class: "flex flex-col items-start gap-4 md:flex-row md:items-baseline md:gap-8") do
              div(class: "w-full md:w-32 shrink-0") do
                p(class: "text-sm text-foreground/70") { format_date(release[:published_at]) }
              end
              div(class: "grid gap-4 w-full") do
                h2(class: "text-2xl font-bold tracking-tight inline-flex items-center gap-2") do
                  plain release[:name]
                end
                div(class: "prose prose-slate dark:prose-invert max-w-none [&>ul]:my-6 [&>ul]:ml-6 [&>ul]:list-disc [&>ul>li]:mt-2 [&>h3]:text-xl [&>h3]:font-bold [&>h2]:text-2xl [&>h2]:font-bold") do
                  raw(release[:body].to_s.html_safe)
                end
              end
            end
            Separator(class: "my-8")
          end
        end
      else
        p(class: "text-muted-foreground") { "No releases found." }
      end
    end
  end

  private

  def releases
    @releases ||= begin
      url = "https://github.com/ruby-ui/ruby_ui/releases.atom"
      feed = RSS::Parser.parse(Net::HTTP.get(URI.parse(url)), false)
      feed.items.map do |item|
        {
          name: item.title.content,
          published_at: item.updated.content.to_s,
          body: item.content.content
        }
      end
    rescue
      []
    end
  end

  def format_date(date_string)
    datetime = DateTime.parse(date_string)
    datetime.strftime("%B %d, %Y")
  rescue
    date_string
  end
end
