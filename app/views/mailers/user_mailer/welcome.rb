module Mailers
  module UserMailer
    class Welcome < ::Mailers::BaseMailer
      def initialize(user:)
        @user = user
      end
      
      def template
        para { "Hello!" }
        para { "Welcome to #{ENV['APP_NAME']}. You're one step closer to building beautiful UIs effortlessly." }
        
        subheader { "Why #{ENV['APP_NAME']} Is Different" }
        para { "We understand the frustrations of building UIs in Ruby. The lack of a comprehensive, easy-to-use, and customizable UI framework can be a real pain. That's why we created #{ENV['APP_NAME']}. It's designed to fill this gap in the Ruby ecosystem, leveraging the strengths of Phlex, TailwindCSS and StimulusJS." }
        
        subheader { "Join the Community" }
        para do
          plain "You're joining a community of developers excited to create custom and complex UIs without needing to write CSS or JS. Come hang out and "
          a(href: ENV['DISCORD_INVITE_LINK']) { "join us on Discord" }
          plain "."
        end
        
        para { "We're thrilled to have you." }

        cta(href: helpers.docs_introduction_url) { "Get Started" }
        
        para { "The #{ENV['APP_NAME']} Team" }
      end
    end
  end
end