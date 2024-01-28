module Mailers
  module UserMailer
    class FutureOfPhlexui < ::Mailers::BaseMailer
      def initialize(user:)
        @user = user
      end
      
      def template
        para { "Hi all, some big news." }

        para { "I have decided that I will open source PhlexUI and am looking for people to be core members." }

        para { "I am at a crossroads in my life where I have decided that I want to take a break from software (At least for a year, most likely more) and help out my mum on the family farm. Software has been something that I have struggled with, purely out of necessity to build the designs that I create. At this point I am burnt out and can see that this way of living is unsustainable for me." }

        para { "I want to stop coding, but I don't want PhlexUI to end. After all these years working with Rails, I feel love for it. However, in my opinion, it's falling behind in some respects (and excelling in others). I think that PhlexUI is one of the missing puzzle pieces for Rails frontend development and I want it to live on in the hope that it will help Rails be successful." }

        para { "I believe that making it open source is the best way forward to ensure its success." }

        para { "I want to be sure that everyone receives this message, so I will send out an email to everyone soon. If you would like a refund, you're most welcome to ask for one (Just reply to this email). If you are happy for the contribution I have made with progressing this package, then from the bottom of my heart, thank you for your support, it means the world." }

        para { "Also, I am sorry for not being able to finish this project. My hope is that it grows stronger in my absence. If you would like to be a core member, please comment below and together we will take the next steps to ensuring this project is completed." }

        para { "George" }
      end
    end
  end
end