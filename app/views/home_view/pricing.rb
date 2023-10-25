# frozen_string_literal: true

class HomeView::Pricing < ApplicationComponent
    def initialize(**attributes)
        @attributes = attributes
    end

    def template
        div(**@attributes, class: tokens("z-10 relative container mx-auto w-full max-w-xl md:max-w-5xl -mt-64 pb-24 lg:pb-32 px-4 flex flex-col items-center gap-y-6", @attributes[:class])) do
            render_header
            render_prices
        end
    end

    def render_header
        div(class: 'text-center flex flex-col items-center gap-y-3 mx-auto max-w-md pb-10') do
            p(class: 'font-semibold text-sky-500') { "Pricing" }
            render Typography::H2.new(class: 'text-center') { "Get everything, forever." }
            p { "Get lifetime access to all components, plus any new content we add in the future for a simple one-time price." }
        end
    end

    def render_prices
        div(class: 'grid grid-cols-1 md:grid-cols-2 gap-6') do
            render_personal
            render_teams
        end
    end

    def render_personal
        div do
            div(class: 'relative flex flex-col p-6 md:p-10 rounded-2xl space-y-6 overflow-hidden bg-card text-card-foreground border') do
                # Plan info
                render_pricing_header(name: 'Personal', description: 'For individuals working on their next big idea.') do
                    svg(
                        xmlns: "http://www.w3.org/2000/svg",
                        viewbox: "0 0 24 24",
                        fill: "currentColor",
                        class: "w-6 h-6"
                    ) do |s|
                        s.path(
                            fill_rule: "evenodd",
                            d:
                            "M7.5 6a4.5 4.5 0 119 0 4.5 4.5 0 01-9 0zM3.751 20.105a8.25 8.25 0 0116.498 0 .75.75 0 01-.437.695A18.683 18.683 0 0112 22.5c-2.786 0-5.433-.608-7.812-1.7a.75.75 0 01-.437-.695z",
                            clip_rule: "evenodd"
                        )
                    end
                end
                # Price
                div(class: 'relative p-6 md:p-10 rounded-2xl space-y-6 overflow-hidden bg-secondary text-secondary-foreground') do
                    div(class: 'flex items-center justify-center space-x-4') do
                        # Price
                        div(class: 'relative') do
                            p(class: 'absolute text-sm line-through text-muted-foreground top-1 -left-2 -translate-y-full -rotate-6') { "$99" }
                            p(class: 'text-5xl font-') { "$49" }
                        end
                        div(class: 'text-sm') do
                            # one time payment
                            p(class: 'font-medium') { "One time payment" }
                            # Plus local taxes
                            p(class: 'text-muted-foreground') { "Plus local taxes" }
                        end
                    end
                    div(class: 'flex flex-col gap-y-2') do
                        render Link.new(variant: :primary, href: "https://buy.stripe.com/eVa6pw25J6RR9l6dQR", class: 'w-full justify-center') { "Pay now" }
                        p(class: 'text-sm text-center text-muted-foreground') { "Lifetime access.  Unlimited projects.  Free updates." }
                    end
                end
                # Features
                div(class: 'flex flex-col gap-y-6') do
                    # Access to all components
                    div(class: 'flex gap-x-4') do
                        # icon
                        svg(
                            xmlns: "http://www.w3.org/2000/svg",
                            viewbox: "0 0 24 24",
                            fill: "currentColor",
                            class: "w-6 h-6 flex-shrink-0 text-muted-foreground"
                        ) do |s|
                            s.path(
                                fill_rule: "evenodd",
                                d:
                                "M11.622 1.602a.75.75 0 01.756 0l2.25 1.313a.75.75 0 01-.756 1.295L12 3.118 10.128 4.21a.75.75 0 11-.756-1.295l2.25-1.313zM5.898 5.81a.75.75 0 01-.27 1.025l-1.14.665 1.14.665a.75.75 0 11-.756 1.295L3.75 8.806v.944a.75.75 0 01-1.5 0V7.5a.75.75 0 01.372-.648l2.25-1.312a.75.75 0 011.026.27zm12.204 0a.75.75 0 011.026-.27l2.25 1.312a.75.75 0 01.372.648v2.25a.75.75 0 01-1.5 0v-.944l-1.122.654a.75.75 0 11-.756-1.295l1.14-.665-1.14-.665a.75.75 0 01-.27-1.025zm-9 5.25a.75.75 0 011.026-.27L12 11.882l1.872-1.092a.75.75 0 11.756 1.295l-1.878 1.096V15a.75.75 0 01-1.5 0v-1.82l-1.878-1.095a.75.75 0 01-.27-1.025zM3 13.5a.75.75 0 01.75.75v1.82l1.878 1.095a.75.75 0 11-.756 1.295l-2.25-1.312a.75.75 0 01-.372-.648v-2.25A.75.75 0 013 13.5zm18 0a.75.75 0 01.75.75v2.25a.75.75 0 01-.372.648l-2.25 1.312a.75.75 0 11-.756-1.295l1.878-1.096V14.25a.75.75 0 01.75-.75zm-9 5.25a.75.75 0 01.75.75v.944l1.122-.654a.75.75 0 11.756 1.295l-2.25 1.313a.75.75 0 01-.756 0l-2.25-1.313a.75.75 0 11.756-1.295l1.122.654V19.5a.75.75 0 01.75-.75z",
                                clip_rule: "evenodd"
                            )
                        end
                        div(class: 'space-y-2 text-sm') do
                            h3(class: "font-medium leading-none tracking-tight") { "Access to all components" }
                            p(class: 'text-muted-foreground') { "Everything you need to build beautiful application UIs, easier and faster than ever before." }
                        end
                    end
                    # Lifetime Access
                    div(class: 'flex gap-x-4') do
                        # icon
                        svg(
                            xmlns: "http://www.w3.org/2000/svg",
                            fill: "none",
                            viewbox: "0 0 24 24",
                            stroke_width: "1.5",
                            stroke: "currentColor",
                            class: "w-6 h-6 flex-shrink-0 text-muted-foreground"
                        ) do |s|
                            s.path(
                                stroke_linecap: "round",
                                stroke_linejoin: "round",
                                d:
                                "M9 12.75L11.25 15 15 9.75M21 12c0 1.268-.63 2.39-1.593 3.068a3.745 3.745 0 01-1.043 3.296 3.745 3.745 0 01-3.296 1.043A3.745 3.745 0 0112 21c-1.268 0-2.39-.63-3.068-1.593a3.746 3.746 0 01-3.296-1.043 3.745 3.745 0 01-1.043-3.296A3.745 3.745 0 013 12c0-1.268.63-2.39 1.593-3.068a3.745 3.745 0 011.043-3.296 3.746 3.746 0 013.296-1.043A3.746 3.746 0 0112 3c1.268 0 2.39.63 3.068 1.593a3.746 3.746 0 013.296 1.043 3.746 3.746 0 011.043 3.296A3.745 3.745 0 0121 12z"
                            )
                        end
                        div(class: 'space-y-2 text-sm') do
                            h3(class: "font-medium leading-none tracking-tight") { "Lifetime Access" }
                            p(class: 'text-muted-foreground') { "Get access to all premium components, plus any new content we add in the future." }
                        end
                    end
                    # Money back guarantee
                    div(class: 'flex gap-x-4') do
                        # icon
                        svg(
                            xmlns: "http://www.w3.org/2000/svg",
                            fill: "none",
                            viewbox: "0 0 24 24",
                            stroke_width: "1.5",
                            stroke: "currentColor",
                            class: "w-6 h-6 flex-shrink-0 text-muted-foreground"
                        ) do |s|
                            s.path(
                                stroke_linecap: "round",
                                stroke_linejoin: "round",
                                d:
                                "M12 6v12m-3-2.818l.879.659c1.171.879 3.07.879 4.242 0 1.172-.879 1.172-2.303 0-3.182C13.536 12.219 12.768 12 12 12c-.725 0-1.45-.22-2.003-.659-1.106-.879-1.106-2.303 0-3.182s2.9-.879 4.006 0l.415.33M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                            )
                        end
                        div(class: 'space-y-2 text-sm') do
                            h3(class: "font-medium leading-none tracking-tight") { "Money back guarantee" }
                            p(class: 'text-muted-foreground') { "If you're not happy with your purchase, we'll refund you in full straight away." }
                        end
                    end
                end
            end
        end
    end

    def render_teams
        div do
            div(class: 'relative flex flex-col p-6 md:p-10 rounded-2xl space-y-6 overflow-hidden bg-secondary text-secondary-foreground') do
                # Plan info
                render_pricing_header(name: 'Teams', description: 'For product teams and agencies.') do
                    svg(
                        xmlns: "http://www.w3.org/2000/svg",
                        viewbox: "0 0 24 24",
                        fill: "currentColor",
                        class: "w-6 h-6"
                    ) do |s|
                        s.path(
                            fill_rule: "evenodd",
                            d:
                            "M8.25 6.75a3.75 3.75 0 117.5 0 3.75 3.75 0 01-7.5 0zM15.75 9.75a3 3 0 116 0 3 3 0 01-6 0zM2.25 9.75a3 3 0 116 0 3 3 0 01-6 0zM6.31 15.117A6.745 6.745 0 0112 12a6.745 6.745 0 016.709 7.498.75.75 0 01-.372.568A12.696 12.696 0 0112 21.75c-2.305 0-4.47-.612-6.337-1.684a.75.75 0 01-.372-.568 6.787 6.787 0 011.019-4.38z",
                            clip_rule: "evenodd"
                        )
                        s.path(
                            d:
                            "M5.082 14.254a8.287 8.287 0 00-1.308 5.135 9.687 9.687 0 01-1.764-.44l-.115-.04a.563.563 0 01-.373-.487l-.01-.121a3.75 3.75 0 013.57-4.047zM20.226 19.389a8.287 8.287 0 00-1.308-5.135 3.75 3.75 0 013.57 4.047l-.01.121a.563.563 0 01-.373.486l-.115.04c-.567.2-1.156.349-1.764.441z"
                        )
                    end
                end
                # Price
                div(class: 'relative p-6 md:p-10 rounded-2xl space-y-6 overflow-hidden bg-card text-card-foreground border') do
                    div(class: 'flex items-center justify-center space-x-4') do
                        # Price
                        div(class: 'relative') do
                            p(class: 'absolute text-sm line-through text-muted-foreground top-1 -left-2 -translate-y-full -rotate-6') { "$199" }
                            p(class: 'text-5xl font-') { "$99" }
                        end
                        div(class: 'text-sm') do
                            # one time payment
                            p(class: 'font-medium') { "One time payment" }
                            # Plus local taxes
                            p(class: 'text-muted-foreground') { "Plus local taxes" }
                        end
                    end
                    div(class: 'flex flex-col gap-y-2') do
                        render Link.new(variant: :primary, href: "https://buy.stripe.com/5kA4ho5hVgsr54QaEG", class: 'w-full justify-center') { "Pay now" }
                        p(class: 'text-sm text-center text-muted-foreground') { "Lifetime access.  Unlimited projects.  Free updates." }
                    end
                end
                # Features
                div(class: 'flex flex-col gap-y-6') do
                    # Everything in Personal plus...
                    div(class: 'flex gap-x-4') do
                        # icon
                        svg(
                            xmlns: "http://www.w3.org/2000/svg",
                            fill: "none",
                            viewbox: "0 0 24 24",
                            stroke_width: "1.5",
                            stroke: "currentColor",
                            class: "w-6 h-6 flex-shrink-0 text-muted-foreground"
                        ) do |s|
                            s.path(
                                stroke_linecap: "round",
                                stroke_linejoin: "round",
                                d:
                                "M13.5 16.875h3.375m0 0h3.375m-3.375 0V13.5m0 3.375v3.375M6 10.5h2.25a2.25 2.25 0 002.25-2.25V6a2.25 2.25 0 00-2.25-2.25H6A2.25 2.25 0 003.75 6v2.25A2.25 2.25 0 006 10.5zm0 9.75h2.25A2.25 2.25 0 0010.5 18v-2.25a2.25 2.25 0 00-2.25-2.25H6a2.25 2.25 0 00-2.25 2.25V18A2.25 2.25 0 006 20.25zm9.75-9.75H18a2.25 2.25 0 002.25-2.25V6A2.25 2.25 0 0018 3.75h-2.25A2.25 2.25 0 0013.5 6v2.25a2.25 2.25 0 002.25 2.25z"
                            )
                        end
                        div(class: 'space-y-2 text-sm') do
                            h3(class: "font-medium leading-none tracking-tight") { "Everything in Personal" }
                            p(class: 'text-muted-foreground') { "Access to all Components, Lifetime Access, Money Back Guarantee plus..." }
                        end
                    end
                    # Unlock access for your entire team
                    div(class: 'flex gap-x-4') do
                        # icon
                        svg(
                            xmlns: "http://www.w3.org/2000/svg",
                            fill: "none",
                            viewbox: "0 0 24 24",
                            stroke_width: "1.5",
                            stroke: "currentColor",
                            class: "w-6 h-6 flex-shrink-0 text-muted-foreground"
                        ) do |s|
                            s.path(
                                stroke_linecap: "round",
                                stroke_linejoin: "round",
                                d:
                                "M13.5 10.5V6.75a4.5 4.5 0 119 0v3.75M3.75 21.75h10.5a2.25 2.25 0 002.25-2.25v-6.75a2.25 2.25 0 00-2.25-2.25H3.75a2.25 2.25 0 00-2.25 2.25v6.75a2.25 2.25 0 002.25 2.25z"
                            )
                        end
                        div(class: 'space-y-2 text-sm') do
                            h3(class: "font-medium leading-none tracking-tight") { "Unlock access for your entire team" }
                            p(class: 'text-muted-foreground') { "Our team licenses include access for up to 25 people to accommodate even the largest teams at your company." }
                        end
                    end
                end
            end
        end
    end

    def render_pricing_header(name:, description:)
        div(class: 'flex items-center space-x-4') do
            if block_given?
                div(class: 'flex-shrink-0 rounded-xl h-10 w-10 flex items-center justify-center text-sky-500 bg-white border') do
                    yield
                end
            end
            div(class: 'space-y-1 text-left') do
                h3(class: "font-semibold leading-none tracking-tight") { name } if name
                p(class: 'text-muted-foreground') { description } if description
            end
        end
    end
end
