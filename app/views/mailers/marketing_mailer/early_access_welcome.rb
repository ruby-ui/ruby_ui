module Mailers
    module MarketingMailer
        class EarlyAccessWelcome < ::Mailers::ApplicationMailer
            def initialize(user:)
                @user = user
            end

            def template
                style = <<~STYLE
                    .p-8 {
                        padding: 2rem;
                    }

                    .space-y-4 > * + * {
                        margin-top: 1rem;
                    }

                    .max-w-2xl {
                        max-width: 42rem;
                    }
                STYLE

                render PhlexUI::Card.new(class: 'p-6 space-y-4 max-w-2xl') do
                    p { "Hello again! 👋" }

                    p { "I have some exciting news: PhlexUI is now officially live for our early access members, and you're among the first to experience it!" }
                    # To ensure you don't miss any important details, I've organized this email into clear sections. So, let's dive in.
                    p { "To ensure you don't miss any important details, I've organized this email into clear sections. So, let's dive in." }

                    # Getting Started with PhlexUI:
                    p do
                        strong { "Getting Started with PhlexUI:" }
                    end
                    # * 		Log In: Simply visit PhlexUI.com and use your purchase email to log in.
                    ol do
                        li do
                            strong { "Log In: " }
                            plain "Simply visit "
                            a(href: "https://phlexui.com") { "PhlexUI.com" }
                            plain " and use your purchase email to log in (#{@user.email})"
                        end
                        # * 		GitHub Integration: Add your GitHub username for exclusive access to our private repositories.
                        li do
                            strong { "GitHub Integration: " }
                            plain "Add your GitHub username for exclusive access to our private repositories."
                        end
                        # * 		Embark on Your PhlexUI Journey: Familiarize yourself with our 'Getting Started' guide and installation instructions. We've kickstarted with Rails using esbuild, and we're eagerly expanding our offerings.
                        li do
                            strong { "Getting started: " }
                            plain "Familiarize yourself with our "
                            a(href: "https://www.phlexui.com/docs/introduction") { "'Getting Started'" }
                            plain " guide and installation instructions. We've kickstarted with Rails using esbuild, and the plan is to add other installation instructions soon."
                        end
                    end

                    # What's Next?
                    p do
                        strong { "What's Next?" }
                    end
                    
                    ul do
                        # * I'd love feedback once you give it a go! I want PhlexUI to be super amazing for lots and lots of people, and the only way to get there is with your help.
                        li { "I'd love feedback once you give it a go! I want PhlexUI to be super amazing for lots and lots of people, and the only way to get there is with your help." }
                        # * Currently, I'm focused on enhancing forms and input components, and building out the rest of the component library.
                        li { "Currently, I'm focused on enhancing forms and input components, and building out the rest of the component library." }
                        # * I plan to build support to copy past the components wrapped in ERB tags. For now you'll have to wrap them yourself.
                        li { "I plan to build support to copy past the components wrapped in ERB tags. For now you'll have to wrap them yourself." }
                    end

                    # Things to Remember:
                    p do
                        strong { "Things to Remember:" }
                    end
                    ul do
                        # * PhlexUI is in early access, so there will be bugs. Please report them to me so I can fix them.
                        li { "PhlexUI is in early access, so there will be bugs. Please report them to me so I can fix them." }
                        # * If you have any framework suggestions for our installation instructions, we'd love to collaborate with you.
                        li { "If you have any framework suggestions for our installation instructions, we'd love to collaborate with you." }
                        # * Join our Discord Community for support, engaging discussions, and to showcase your PhlexUI projects. Currently I'm the only one there, so I'd love some friends.
                        li do
                            plain "Join our "
                            a(href: "https://discord.gg/7r2t2GAvp7") { "Discord Community" }
                            plain " for support, to provide ideas, and to showcase your PhlexUI projects. Currently I'm the only one there, so I'd love some friends."
                        end
                        # * Keep in mind that the library is subject to change lots before we get to v1.0.0
                        li { "Keep in mind that the library is subject to change lots before we get to v1.0.0" }
                    end

                    # Ok, we made it! Before I go, I just want to say a heartfelt thank you for your support and enthusiasm towards this project. The positive response has been overwhelming, and it's a pleasure to build something that resonates with so many.
                    p { "Ok, we made it! Before I go, I just want to say a heartfelt thank you for your support and enthusiasm towards this project. The positive response has been overwhelming, and it's a pleasure to build something that resonates with so many." }

                    
                    # Cheers,
                    p { "Cheers," }
                    # George
                    p { "George" }

                    # Ps. It's very late in Australia, so I'm off to bed now. I will be able to respond tomorrow to anything that comes up.
                    p { "Ps. It's very late in Australia, so I'm off to bed now. I will be able to respond tomorrow to anything that comes up." }
                end
            end
        end
    end
end