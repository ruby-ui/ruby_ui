module Mailers
  module UserMailer
    class Welcome < Phlex::HTML
      def initialize(user:)
        @user = user
      end
      
      def template
        p { "Hello there," }
        p { "Welcome to #{ENV['APP_NAME']}! We're excited to have you on board. This email will provide you with some information about #{ENV['APP_NAME']} and why it was built." }
        
        h2 { "Why #{ENV['APP_NAME']} Exists" }
        p { "We understand the frustrations of building UIs in Ruby. The lack of a comprehensive, easy-to-use, and customizable UI framework can be a real pain. That's why we created #{ENV['APP_NAME']}. It's designed to fill this gap in the Ruby ecosystem, leveraging the strengths of Phlex, TailwindCSS and StimulusJS." }
        
        h2 { "What #{ENV['APP_NAME']} Can Do For You" }
        p { "#{ENV['APP_NAME']} is more than just a reusable UI component library. It's a tool that empowers you to create custom and complex UIs without needing to write CSS or JS. Say goodbye to the headaches of UI development and hello to a smoother, more efficient workflow." }
        
        h2 { "Ready to Dive In?" }
        p do
          plain "To get started with #{ENV['APP_NAME']}, check out our "
          a(href: helpers.docs_introduction_url) { "Getting Started" }
          plain " guide. If you have any questions or need support, don't hesitate to reach out to us at "
          a(href: "mailto:#{ENV['SUPPORT_EMAIL']}") { "#{ENV['SUPPORT_EMAIL']}" }
          plain ". We're here to help you make the most of #{ENV['APP_NAME']}."
        end
        
        p { "Happy coding!" }
        p { "The #{ENV['APP_NAME']} Team" }
      end
    end
  end
end