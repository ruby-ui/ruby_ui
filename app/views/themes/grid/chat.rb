# frozen_string_literal: true

module Themes
  module Grid
    class Chat < ApplicationComponent
      MESSAGES = [
        "You should checkout RBUI's new release, it makes life sooo much easier",
        "What's RBUI?",
        "Don't ask questions, just get on that ASAP and thank me later",
        "Alright, alright, I'll check it out"
      ]

      def view_template
        Card(class: "p-8 space-y-6") do
          header
          messages(MESSAGES)
          message_form
        end
      end

      private

      def header
        div(class: "flex items-center justify-between") do
          div(class: "flex items-center space-x-4") do
            div do
              TypographyP(class: "font-medium") { "Joel Drapper" }
              TypographyMuted { "joel@drapper.me" }
            end
          end
          Tooltip do
            TooltipTrigger do
              Button(variant: :outline, icon: true) do
                bookmark_icon
              end
            end
            TooltipContent do
              TypographyP { "Save contact" }
            end
          end
        end
      end

      def messages(messages)
        div(class: "space-y-4") do
          messages.each_with_index do |message, index|
            message(message, right: index.odd?)
          end
        end
      end

      def message(content, right: false)
        div(class: tokens("w-full flex", -> { right } => "justify-end")) do
          div(class:
              tokens(
                "rounded-2xl p-4 w-3/4",
                -> { right } => "bg-primary text-primary-foreground rounded-br-sm",
                -> { !right } => "bg-muted text-foreground rounded-bl-sm"
              )) do
            content
          end
        end
      end

      def message_form
        div(class: "flex w-full items-center space-x-2") do
          Input(type: "message", placeholder: "Write something...")
          Button { "Send" }
        end
      end

      def bookmark_icon
        svg(
          xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewbox: "0 0 24 24",
          stroke_width: "1.5",
          stroke: "currentColor",
          class: "w-4 h-4"
        ) do |s|
          s.path(
            stroke_linecap: "round",
            stroke_linejoin: "round",
            d:
              "M17.593 3.322c1.1.128 1.907 1.077 1.907 2.185V21L12 17.25 4.5 21V5.507c0-1.108.806-2.057 1.907-2.185a48.507 48.507 0 0111.186 0z"
          )
        end
      end
    end
  end
end
