# frozen_string_literal: true

class HomeView::MeetTheMaker < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template
        div(class: 'container mx-auto max-w-5xl pb-24 lg:pb-32 px-4') do
            div(class: 'text-center flex flex-col items-center gap-y-3 mx-auto max-w-md pb-16') do
                p(class: 'font-semibold text-sky-500') { "Meet the Maker" }
                render PhlexUI::Typography::H2.new(class: 'text-center') { "My name is George" }
                p { "I've been building Rails apps for 5+ years, both professionally and as a hobby. I've taught 100's of students and also been trained professionally in graphic design." }
                render PhlexUI::Link.new(variant: :outline, href: "https://twitter.com/george_kettle", class: 'mt-2') { "Find me on Twitter" }
            end
            div(class: 'grid gap-4 grid-cols-2') do
                div(class: 'col-span-1 row-span-2 relative') do
        
                        img(
                            alt: "George Kettle - PhlexUI",
                            loading: "lazy",
                            class: "rounded-2xl object-cover border",
                            style:
                                "position:absolute;height:100%;width:100%;inset:0;color:transparent",
                            src:
                                helpers.image_url("george_nature.jpg")
                        )
                end
                div(class: 'col-span-1') do
                    render PhlexUI::AspectRatio.new(aspect_ratio: "16/9") do
                        img(
                            alt: "George Kettle - PhlexUI",
                            loading: "lazy",
                            class: "rounded-2xl object-cover border",
                            style:
                                "position:absolute;height:100%;width:100%;inset:0;color:transparent",
                            src:
                                helpers.image_url("george_lewagon.jpg")
                        )
                    end
                end
                div(class: 'col-span-1') do
                    render PhlexUI::AspectRatio.new(aspect_ratio: "16/9") do
                        img(
                            alt: "George Kettle - PhlexUI",
                            loading: "lazy",
                            class: "rounded-2xl object-cover border",
                            style:
                                "position:absolute;height:100%;width:100%;inset:0;color:transparent",
                            src:
                                helpers.image_url("george_computer.jpg")
                        )
                    end
                end
            end
        end
    end
end
