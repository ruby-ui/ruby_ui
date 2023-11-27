# frozen_string_literal: true

class Signins::CheckYourEmailView < ApplicationView
    def initialize(email: nil)
        @email = email
    end

    def template
        render PhlexUI::Card.new(class: 'w-full overflow-hidden') do
            render PhlexUI::AspectRatio.new(aspect_ratio: "2/1", class: "border-b") do
                img(
                alt: "Placeholder",
                loading: "lazy",
                src:
                    helpers.image_url('email_sent.png')
                )
            end
            render PhlexUI::Card::Header.new do
                render PhlexUI::Card::Title.new { 'We sent a link to your email' }
                render PhlexUI::Card::Description.new { "In your email, you will find a sign in link. If it doesn't arrive straight away, give it 30 seconds." }
            end
            render PhlexUI::Card::Footer.new(class: 'space-y-1') do
                render PhlexUI::Link.new(href: "https://mail.google.com", variant: :outline, target: :_blank, class: 'w-full relative') do
                    div(class: 'absolute left-2 top-1/2 -translate-y-1/2') do
                        gmail_logo
                    end
                    plain "Check Gmail"
                end
                render PhlexUI::Link.new(href: "https://mail.yahoo.com", variant: :outline, target: :_blank, class: 'w-full relative') do
                    div(class: 'absolute left-2 top-1/2 -translate-y-1/2') do
                        yahoo_logo
                    end
                    plain "Check Yahoo Mail"
                end
                render PhlexUI::Link.new(href: "https://outlook.live.com", variant: :outline, target: :_blank, class: 'w-full relative') do
                    div(class: 'absolute left-2 top-1/2 -translate-y-1/2') do
                        outlook_logo
                    end
                    plain "Check Outlook"
                end
            end
        end
        render PhlexUI::Typography::Muted.new(href: helpers.signin_path, variant: :link, class: 'w-full text-center pt-2') do
            plain "Didn't receive an email?"
            render PhlexUI::Link.new(href: helpers.new_signin_path, variant: :link, class: '!px-2') { "Try again" }
        end
    end

    private

    def yahoo_logo
        svg(
            xmlns: "http://www.w3.org/2000/svg",
            clip_rule: "evenodd",
            fill_rule: "evenodd",
            image_rendering: "optimizeQuality",
            shape_rendering: "geometricPrecision",
            text_rendering: "geometricPrecision",
            viewbox: "-0.01 -0.01 7110.9800000000005 1980.03",
            class: 'h-3 mr-1'
        ) do |s|
            s.path(
                d:
                "M1329.67 490.18H910.49l-245.66 585.08-245.66-585.08H-.01c152.27 362.65 304.48 725.36 456.81 1087.97l-168.74 401.87h419.18c209.62-499.25 414.16-993.83 622.42-1489.83zM6659.85 3.11h451.12l-407.94 985.71h-451.12zM6362.8 1083.88c140.46 0 254.34 113.87 254.34 254.34s-113.87 254.34-254.34 254.34-254.34-113.87-254.34-254.34c0-140.46 113.87-254.34 254.34-254.34zm-887-623.29c315.88 0 571.94 256.07 571.94 571.94 0 315.88-256.07 571.94-571.94 571.94-315.88 0-571.94-256.07-571.94-571.94 0-315.88 256.07-571.94 571.94-571.94zm0 348.62c123.34 0 223.33 99.99 223.33 223.33s-99.99 223.33-223.33 223.33-223.33-99.99-223.33-223.33 99.99-223.33 223.33-223.33zM4247.93 460.59c315.88 0 571.94 256.07 571.94 571.94 0 315.88-256.07 571.94-571.94 571.94-315.88 0-571.94-256.07-571.94-571.94 0-315.88 256.07-571.94 571.94-571.94zm0 348.62c123.34 0 223.33 99.99 223.33 223.33s-99.99 223.33-223.33 223.33-223.33-99.99-223.33-223.33 99.99-223.33 223.33-223.33zM2559.39 0h378.21v587.98s66.17-127.39 284.75-127.39 358.77 96.17 361.57 489.96v642.01h-378.21V950.55c0-74.04-60.02-134.06-134.06-134.06-75.75 0-135.89 62.28-134 137.86l-.06 638.21h-378.21V-.01zM2044.4 490.18h378.21v1102.39H2044.4v-103.92c-84.7 72.68-190.25 115.84-304.71 115.84-278.92 0-505.03-256.07-505.03-571.94 0-315.88 226.11-571.94 505.03-571.94 114.46 0 220.02 43.15 304.71 115.84V490.2zm-213.03 319.03c123.34 0 223.33 99.99 223.33 223.33s-99.99 223.33-223.33 223.33-223.33-99.99-223.33-223.33 99.99-223.33 223.33-223.33z",
                fill: "#6101d1"
            )
        end
    end

    def gmail_logo
        svg(
            xmlns: "http://www.w3.org/2000/svg",
            viewbox: "0 49.4 512 399.4200000000001",
            class: 'h-3 mr-1'
        ) do |s|
            s.g(fill: "none", fill_rule: "evenodd") do
                s.g(fill_rule: "nonzero") do
                s.path(
                    d:
                    "M34.91 448.818h81.454V251L0 163.727V413.91c0 19.287 15.622 34.91 34.91 34.91z",
                    fill: "#4285f4"
                )
                s.path(
                    d:
                    "M395.636 448.818h81.455c19.287 0 34.909-15.622 34.909-34.909V163.727L395.636 251z",
                    fill: "#34a853"
                )
                s.path(
                    d:
                    "M395.636 99.727V251L512 163.727v-46.545c0-43.142-49.25-67.782-83.782-41.891z",
                    fill: "#fbbc04"
                )
                end
                s.path(
                    d: "M116.364 251V99.727L256 204.455 395.636 99.727V251L256 355.727z",
                    fill: "#ea4335"
                )
                s.path(
                    d:
                        "M0 117.182v46.545L116.364 251V99.727L83.782 75.291C49.25 49.4 0 74.04 0 117.18z",
                    fill: "#c5221f",
                    fill_rule: "nonzero"
                )
            end
        end
    end

    def outlook_logo
        svg(
            xmlns: "http://www.w3.org/2000/svg",
            viewbox: "-0.12979372698077785 0 33.25199671942124 32",
            class: 'h-3.5 mr-1'
        ) do |s|
            s.path(
                d:
                "M28.596 2H11.404A1.404 1.404 0 0 0 10 3.404V5l9.69 3L30 5V3.404A1.404 1.404 0 0 0 28.596 2z",
                fill: "#0364b8"
            )
            s.path(
                d:
                "M31.65 17.405A11.341 11.341 0 0 0 32 16a.666.666 0 0 0-.333-.576l-.013-.008-.004-.002L20.812 9.24a1.499 1.499 0 0 0-.145-.083 1.5 1.5 0 0 0-1.334 0 1.49 1.49 0 0 0-.145.082L8.35 15.415l-.004.002-.012.007A.666.666 0 0 0 8 16a11.344 11.344 0 0 0 .35 1.405l11.492 8.405z",
                fill: "#0a2767"
            )
            s.path(d: "M24 5h-7l-2.021 3L17 11l7 6h6v-6z", fill: "#28a8ea")
            s.path(d: "M10 5h7v6h-7z", fill: "#0078d4")
            s.path(d: "M24 5h6v6h-6z", fill: "#50d9ff")
            s.path(d: "M24 17l-7-6h-7v6l7 6 10.832 1.768z", fill: "#0364b8")
            s.path(d: "M10.031 5H30", fill: "none")
            s.path(d: "M17 11h7v6h-7z", fill: "#0078d4")
            s.path(d: "M10 17h7v6h-7z", fill: "#064a8c")
            s.path(d: "M24 17h6v6h-6z", fill: "#0078d4")
            s.path(
                d:
                "M20.19 25.218l-11.793-8.6.495-.87s10.745 6.12 10.909 6.212a.528.528 0 0 0 .42-.012l10.933-6.23.496.869z",
                fill: "#0a2767",
                opacity: ".5"
            )
            s.path(
                d:
                "M31.667 16.577l-.014.008-.003.002-10.838 6.174a1.497 1.497 0 0 1-1.46.091l3.774 5.061 8.254 1.797v.004A1.498 1.498 0 0 0 32 28.5V16a.666.666 0 0 1-.333.577z",
                fill: "#1490df"
            )
            s.path(
                d:
                "M32 28.5v-.738l-9.983-5.688-1.205.687a1.497 1.497 0 0 1-1.46.091l3.774 5.061 8.254 1.797v.004A1.498 1.498 0 0 0 32 28.5z",
                opacity: ".05"
            )
            s.path(
                d:
                "M31.95 28.883L21.007 22.65l-.195.11a1.497 1.497 0 0 1-1.46.092l3.774 5.061 8.254 1.797v.004a1.501 1.501 0 0 0 .57-.83z",
                opacity: ".1"
            )
            s.path(
                d:
                "M8.35 16.59v-.01h-.01l-.03-.02A.65.65 0 0 1 8 16v12.5A1.498 1.498 0 0 0 9.5 30h21a1.503 1.503 0 0 0 .37-.05.637.637 0 0 0 .18-.06.142.142 0 0 0 .06-.02 1.048 1.048 0 0 0 .23-.13c.02-.01.03-.01.04-.03z",
                fill: "#28a8ea"
            )
            s.path(
                d:
                "M18 24.667V8.333A1.337 1.337 0 0 0 16.667 7H10.03V14.456l-1.68.958-.005.002-.012.007A.666.666 0 0 0 8 16v.005V16 26h8.667A1.337 1.337 0 0 0 18 24.667z",
                opacity: ".1"
            )
            s.path(
                d:
                "M17 25.667V9.333A1.337 1.337 0 0 0 15.667 8H10.03V14.456l-1.68.958-.005.002-.012.007A.666.666 0 0 0 8 16v.005V16 27h7.667A1.337 1.337 0 0 0 17 25.667z",
                opacity: ".2"
            )
            s.path(
                d:
                "M17 23.667V9.333A1.337 1.337 0 0 0 15.667 8H10.03V14.456l-1.68.958-.005.002-.012.007A.666.666 0 0 0 8 16v.005V16 25h7.667A1.337 1.337 0 0 0 17 23.667z",
                opacity: ".2"
            )
            s.path(
                d:
                "M16 23.667V9.333A1.337 1.337 0 0 0 14.667 8H10.03V14.456l-1.68.958-.005.002-.012.007A.666.666 0 0 0 8 16v.005V16 25h6.667A1.337 1.337 0 0 0 16 23.667z",
                opacity: ".2"
            )
            s.path(
                d:
                "M1.333 8h13.334A1.333 1.333 0 0 1 16 9.333v13.334A1.333 1.333 0 0 1 14.667 24H1.333A1.333 1.333 0 0 1 0 22.667V9.333A1.333 1.333 0 0 1 1.333 8z",
                fill: "#0078d4"
            )
            s.path(
                d:
                "M3.867 13.468a4.181 4.181 0 0 1 1.642-1.814A4.965 4.965 0 0 1 8.119 11a4.617 4.617 0 0 1 2.413.62 4.14 4.14 0 0 1 1.598 1.733 5.597 5.597 0 0 1 .56 2.55 5.901 5.901 0 0 1-.577 2.666 4.239 4.239 0 0 1-1.645 1.794A4.8 4.8 0 0 1 7.963 21a4.729 4.729 0 0 1-2.468-.627 4.204 4.204 0 0 1-1.618-1.736 5.459 5.459 0 0 1-.567-2.519 6.055 6.055 0 0 1 .557-2.65zm1.75 4.258a2.716 2.716 0 0 0 .923 1.194 2.411 2.411 0 0 0 1.443.435 2.533 2.533 0 0 0 1.541-.449 2.603 2.603 0 0 0 .897-1.197 4.626 4.626 0 0 0 .286-1.665 5.063 5.063 0 0 0-.27-1.686 2.669 2.669 0 0 0-.866-1.24 2.387 2.387 0 0 0-1.527-.473 2.493 2.493 0 0 0-1.477.439 2.741 2.741 0 0 0-.944 1.203 4.776 4.776 0 0 0-.007 3.44z",
                fill: "#fff"
            )
            s.path(d: "M0 0h32v32H0z", fill: "none")
        end
    end
end