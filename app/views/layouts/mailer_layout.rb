class MailerLayout < Phlex::HTML
  include Phlex::Rails::Layout

  def template(&block)
    style do
      <<-CSS
        :root {
          --background: hsl(0, 0%, 100%);
          --foreground: hsl(0, 0%, 3.9%);
          --primary: hsl(0, 0%, 9%);
          --primary-foreground: hsl(0, 0%, 98%);
        }

        body { 
          font-family: Helvetica, sans-serif;
          background-color: var(--background);
        }

        .logo {
          margin-bottom: 0.6rem;
        }

        p {
          font-size: 1rem;
          line-height: 1.5rem;
          font-weight: 400;
          color: var(--foreground);
          margin-top: 0;
          margin-bottom: 1rem;
        }

        strong {
          font-weight: 600;
        }

        .button {
          background-color: var(--primary);
          color: var(--primary-foreground);
          display: inline-flex;
          padding-top: 0.5rem;
          padding-bottom: 0.5rem;
          padding-left: 1rem;
          padding-right: 1rem;
          justify-content: center;
          align-items: center;
          border-radius: 0.375rem;
          font-size: 0.875rem;
          line-height: 1.25rem;
          font-weight: 500;
          white-space: nowrap;
          transition-property: color, background-color, border-color, text-decoration-color, fill, stroke;
          transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
          transition-duration: 300ms;
          box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
          text-decoration: none;
        }
      CSS
    end
    body do
      img(src: helpers.image_url('logo.svg'), height: "20", class: 'logo')
      main(&block)
    end
  end
end