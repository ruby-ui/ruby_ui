class MailerLayout < Phlex::HTML
  include Phlex::Rails::Layout

  def template(&block)
    html do
      head do
        meta(name: "viewport", content: "width=device-width, initial-scale=1.0")
        meta(http_equiv: "Content-Type", content: "text/html; charset=UTF-8")
        title { "Simple Transactional Email" }
        style(media: "all", type: "text/css") do
          <<-CSS
            :root {
              --font: Helvetica, sans-serif;
              --background: hsl(0, 0%, 100%);
              --foreground: hsl(0, 0%, 3.9%);
              --primary: hsl(0, 0%, 9%);
              --primary-foreground: hsl(0, 0%, 98%);
              --muted: hsl(0, 0%, 96.1%);
              --muted-foreground: hsl(0, 0%, 45.1%);
              --border: hsl(0, 0%, 89.8%);
              --radius: 0.4rem;
            }
            body {
              font-family: var(--font);
              -webkit-font-smoothing: antialiased;
              font-size: 16px;
              line-height: 1.3;
              -ms-text-size-adjust: 100%;
              -webkit-text-size-adjust: 100%;
            }
            table {
              border-collapse: separate;
              mso-table-lspace: 0;
              mso-table-rspace: 0;
              width: 100%;
            }
            table td {
              font-family: var(--font);
              font-size: 16px;
              vertical-align: top;
            }
            body {
              background-color: var(--muted);
              margin: 0;
              padding: 0 4px;
            }
            .body {
              background-color: var(--muted);
              width: 100%;
            }
            .container {
              margin: 0 auto !important;
              max-width: 600px;
              padding: 0;
              padding-top: 24px;
              width: 600px;
            }
            .content {
              box-sizing: border-box;
              display: block;
              margin: 0 auto;
              max-width: 600px;
              padding: 0;
            }
            .main-wrapper {
              border-radius: calc(var(--radius) * 2);
              overflow: hidden;
              border: 1px solid var(--border);
              background: var(--background);
            }
            .main {
              width: 100%;
            }
            .wrapper {
              box-sizing: border-box;
              padding: 24px;
            }
            .footer {
              clear: both;
              padding-top: 24px;
              text-align: center;
              width: 100%;
            }
            .footer td, .footer p, .footer span, .footer a {
              color: var(--muted-foreground);
              font-size: 16px;
              text-align: center;
            }
            p {
              font-family: var(--font);
              color: var(--muted-foreground);
              font-size: 16px;
              font-weight: normal;
              margin: 0;
              margin-bottom: 16px;
              line-height: 1.7;
            }
            strong {
              font-weight: 600;
              color: var(--foreground);
            }
            h2 {
              font-size: 20px;
              letter-spacing: -0.5px;
            }
            a {
              color: var(--primary);
              text-decoration: underline;
            }
            .btn {
              box-sizing: border-box;
              margin-bottom: 16px;
            }
            .btn > tbody > tr > td {
              padding-bottom: 16px;
            }
            .btn table {
              width: auto;
            }
            .btn table td {
              background-color: var(--background);
              border-radius: var(--radius);
              text-align: center;
            }
            .btn a {
              background-color: var(--background);
              border: solid 2px var(--primary);
              border-radius: var(--radius);
              box-sizing: border-box;
              color: var(--primary-foreground);
              cursor: pointer;
              display: inline-block;
              font-size: 16px;
              font-weight: 600;
              margin: 0;
              padding: 8px 24px;
              text-decoration: none;
              text-transform: capitalize;
            }
            .btn-primary table td {
              background-color: var(--primary);
            }
            .btn-primary a {
              background-color: var(--primary);
              border-color: var(--primary);
              color: var(--primary-foreground);
            }
            @media all {
              .btn-primary table td:hover {
                opacity: 0.9 !important;
              }
            }
            .btn-primary a:hover {
              opacity: 0.9 !important;
            }
            @media {
              .last {
                margin-bottom: 0;
              }
            }
            .first {
              margin-top: 0;
            }
            .align-center {
              text-align: center;
            }
            .align-right {
              text-align: right;
            }
            .align-left {
              text-align: left;
            }
            .text-link {
              color: var(--primary) !important;
              text-decoration: underline !important;
            }
            .clear {
              clear: both;
            }
            .mt0 {
              margin-top: 0;
            }
            .mb0 {
              margin-bottom: 0;
            }
            .preheader {
              color: transparent;
              display: none;
              height: 0;
              max-height: 0;
              max-width: 0;
              opacity: 0;
              overflow: hidden;
              mso-hide: all;
              visibility: hidden;
              width: 0;
            }
            .powered-by a {
              text-decoration: none;
            }
            .logo-container {
              text-align: center;
              padding: 20px 10px;
            }
            @media only screen and (max-width:640px) {
              .main p, .main td, .main span {
                font-size: 16px !important;
              }
            }
            .main {
              border-radius: var(--radius) * 4;
            }
            .wrapper {
              padding: 30px !important;
            }
            .content {
              padding: 0 !important;
            }
            .container {
              padding: 0 !important;
              padding-top: 8px !important;
              width: 100% !important;
            }
            .btn table {
              max-width: 100% !important;
            }
            .btn a {
              font-size: 16px !important;
              max-width: 100% !important;
              width: 100% !important;
            }
            @media all {
              .ExternalClass {
                width: 100%;
              }
            }
            .ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div {
              line-height: 100%;
            }
            .apple-link a {
              color: inherit !important;
              font-family: inherit !important;
              font-size: inherit !important;
              font-weight: inherit !important;
              line-height: inherit !important;
              text-decoration: none !important;
            }
            #MessageViewBody a {
              color: inherit;
              text-decoration: none;
              font-size: inherit;
              font-family: inherit;
              font-weight: inherit;
              line-height: inherit;
            }
          CSS
        end
      end
      body do
        table(
          role: "presentation",
          border: "0",
          cellpadding: "0",
          cellspacing: "0",
          class: "body"
        ) do
          tr do
            td { " " }
            td(class: "container") do
              div(class: "content") do
                comment { "START CENTERED WHITE CONTAINER" }
                # span(class: "preheader") do
                #   "This is preheader text. Some clients will show this text as a preview."
                # end

                div(class: "logo-container") do
                  a(href: ENV["HOST"]) do
                    img(src: helpers.image_url("logo.svg"), alt: ENV["APP_NAME"], height: "20")
                  end
                end

                div(class: "main-wrapper") do
                  table(
                    role: "presentation",
                    border: "0",
                    cellpadding: "0",
                    cellspacing: "0",
                    class: "main"
                  ) do
                    comment { "START MAIN CONTENT AREA" }
                    tr do
                      td(class: "wrapper") do
                        yield
                      end
                    end
                    comment { "END MAIN CONTENT AREA" }
                  end
                end
                comment { "START FOOTER" }
                div(class: "footer") do
                  table(
                    role: "presentation",
                    border: "0",
                    cellpadding: "0",
                    cellspacing: "0"
                  ) do
                    tr do
                      td(class: "content-block") do
                        span(class: "apple-link") do
                          "#{ENV["APP_NAME"]}, #{ENV["COMPANY_ADDRESS"]}"
                        end
                      end
                    end
                  end
                end
                comment { "END FOOTER" }
                comment { "END CENTERED WHITE CONTAINER" }
              end
            end
            td { " " }
          end
        end
      end
    end
  end
end
