# frozen_string_literal: true

class Docs::GettingStarted::IntroductionView < ApplicationView
  def view_template
    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Introduction", description: "Reusable UI components for Ruby developers")

      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new { "About" }
        render PhlexUI::Typography::P.new do
          plain "PhlexUI is a UI framework for Ruby developers, built on top of "
          render PhlexUI::Typography::InlineLink.new(href: "http://phlex.fun") { "Phlex" }
          plain ", "
          render PhlexUI::Typography::InlineLink.new(href: "https://tailwindcss.com") { "TailwindCSS" }
          plain " and "
          render PhlexUI::Typography::InlineLink.new(href: "https://stimulus.hotwire.dev") { "Stimulus JS" }
          plain ". It provides a set of components that are easy to use, and easy to customize."
        end
      end

      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new { "Core ingredients" }
        render PhlexUI::Typography::P.new { "PhlexUI is built on top of 3 core ingredients: " }
        render PhlexUI::Typography::List.new do
          render PhlexUI::Typography::ListItem.new(class: "space-y-2") do
            span(class: "font-bold") { "Phlex" }
            plain " - A framework for building fast, reusable, testable views in pure Ruby."
          end
          render PhlexUI::Typography::ListItem.new(class: "space-y-2") do
            span(class: "font-bold") { "TailwindCSS" }
            plain " - A utility-first CSS framework for rapidly building custom designs."
          end
          render PhlexUI::Typography::ListItem.new(class: "space-y-2") do
            span(class: "font-bold") { "Stimulus JS" }
            plain " - A modest JavaScript framework for the HTML you already have."
          end
        end
      end

      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new { "Why I built PhlexUI" }
        render PhlexUI::Typography::P.new do
          plain "Many Ruby developers are familiar with "
          render PhlexUI::Typography::InlineLink.new(href: "https://rubyonrails.org") { "Rails" }
          plain ", and the "
          render PhlexUI::Typography::InlineLink.new(href: "https://guides.rubyonrails.org/layouts_and_rendering.html") { "convention over configuration" }
          plain " approach it takes. PhlexUI is built on the same principles, providing a set of components that are easy to use, and easy to customize."
        end
        render PhlexUI::Typography::P.new do
          plain "PhlexUI was born out of a desire for a comprehensive UI framework designed with Ruby developers in mind. While I've previously utilized TailwindUI and other solutions, none seemed to fit just right. The plethora of UI component libraries available for JavaScript frameworks highlighted a gap in the Ruby ecosystem, which PhlexUI aims to fill."
        end
        render PhlexUI::Typography::P.new do
          plain "Upon discovering Phlex, it became clear that it was the ideal foundation for such a library. It offered the potential for a powerful, easy-to-use, and customizable component library when paired with StimulusJS. The goal was to create a tool that leverages the strengths of TailwindCSS and StimulusJS, providing Ruby developers with a comprehensive UI solution that is stylable at the HTML level."
        end
      end

      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new { "Goals of PhlexUI" }
        render PhlexUI::Typography::List.new(numbered: true) do
          render PhlexUI::Typography::ListItem.new { "Create a reusable UI component library specifically for Ruby devs" }
          render PhlexUI::Typography::ListItem.new { "Enable Ruby devs to create custom and complex UIs without needing to write CSS or JS" }
        end
      end

      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new { "My experience using Phlex" }
        render PhlexUI::Typography::P.new do
          span(class: "font-medium") { "I was initially skeptical about Phlex. " }
          plain "I worried about using an abstraction layer on top of HTML and thought this would be a bad move. However, after trying it I realised that I was wrong, and "
          span(class: "font-medium") { "I know others who have had the same experience as myself" }
          plain "."
        end
        render PhlexUI::Typography::P.new { "After some time using Phlex, it's obvious to me that this is a better way to render your views in Ruby apps. Phlex is intuitive and simple. It is also incredibly fast (12x faster than ERB, 5x faster than ViewComponent), it also makes your code more organised and leads to a better developer experience." }
        render PhlexUI::Typography::Large.new { "Same same, but different" }
        render PhlexUI::Typography::P.new do
          plain "Phlex is essentially just HTML in Ruby form, bundled into a component. It's a simple concept, but it's incredibly powerful. It allows you to write your views in pure Ruby, without the need for a templating language. This means you can use all the features of Ruby, including loops, conditionals, and more."
        end
        render PhlexUI::Typography::P.new do
          plain "As an example, if you want to render a "
          render PhlexUI::Typography::InlineCode.new { "<p class='text-sm font-muted-foreground'>Phlex. Same same, but different.</p>" }
          plain " element, you can do it like this "
          render PhlexUI::Typography::InlineCode.new { "p(class: 'text-sm font-muted-foreground') { 'Phlex. Same same, but different.' }" }
          plain "."
        end
        render PhlexUI::Typography::P.new do
          plain "This is a simple example, but it's easy to see how this can be scaled up to more complex views. "
          span(class: "font-medium") { "It's only natural that we use logic to build HTML" }
          plain ". Phlex simplifies this process, making it easier to convert data structures into HTML."
        end
      end

      div(class: "space-y-4") do
        render PhlexUI::Typography::H2.new { "Acknowledgments" }
        render PhlexUI::Typography::P.new { "I'd like to thank the following projects and people for helping me build PhlexUI" }
        render PhlexUI::Typography::List.new do
          render PhlexUI::Typography::ListItem.new do
            render PhlexUI::Typography::InlineLink.new(href: "https://github.com/joeldrapper") { "Joel Drapper" }
            plain " - Thanks for creating Phlex, and for your support and advice."
          end
          render PhlexUI::Typography::ListItem.new do
            render PhlexUI::Typography::InlineLink.new(href: "https://phlex.fun") { "Phlex" }
            plain " - The foundation of PhlexUI."
          end
          render PhlexUI::Typography::ListItem.new do
            render PhlexUI::Typography::InlineLink.new(href: "https://stimulus.hotwired.dev") { "Stimulus JS" }
            plain " - A quicker way to write JavaScript."
          end
          render PhlexUI::Typography::ListItem.new do
            render PhlexUI::Typography::InlineLink.new(href: "http://tailwindcss.com") { "TailwindCSS" }
            plain " - I wouldn't build without it."
          end
          render PhlexUI::Typography::ListItem.new do
            render PhlexUI::Typography::InlineLink.new(href: "https://twitter.com/george_kettle") { "My Twitter followers" }
            plain " - Thanks for all the ideas, feedback and support."
          end
        end
      end
    end
  end
end
