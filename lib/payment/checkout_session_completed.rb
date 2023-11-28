module Payment
    class CheckoutSessionCompleted
        PLAN_TYPES = {
            ENV['STRIPE_PERSONAL_PRODUCT_ID'] => 'personal',
            ENV['STRIPE_TEAM_PRODUCT_ID'] => 'team'
        }
        
        def initialize(event)
            @event = event
        end

        def call
            checkout_session = Stripe::Checkout::Session.retrieve({
                id: @event.data.object.id,
                expand: ['line_items']
            })
            email = checkout_session.customer_details.email
            user = EmailAuth::FindsOrCreatesUser.new(email: email).call
            
            # Record which plan the user has purchased
            lines = checkout_session.line_items
            lines.each do |line|
                plan_type = PLAN_TYPES[line.price.product]
                user.update(plan: plan_type) if plan_type
            end
        rescue Stripe::StripeError => e
            # Handle Stripe API errors
            puts "Stripe error: #{e.message}"
        rescue StandardError => e
            # Handle other unexpected errors
            puts "Unexpected error: #{e.message}"
        end
    end
end