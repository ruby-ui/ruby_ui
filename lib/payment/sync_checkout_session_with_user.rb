module Payment
    class SyncCheckoutSessionWithUser
        PLAN_TYPES = {
            ENV['STRIPE_PERSONAL_PRODUCT_ID'] => 'personal',
            ENV['STRIPE_TEAM_PRODUCT_ID'] => 'team'
        }

        def initialize(id)
            @id = id
        end

        def call
            checkout_session = retrieve_checkout_session
            return if invalid_checkout_session?(checkout_session)

            user = find_or_create_user(checkout_session.customer_details&.email)
            update_user_plan(user, checkout_session.line_items)
            puts "Successfully synced checkout session #{@id} with user #{user.email}"
        rescue Stripe::StripeError => e
            log_error("Stripe error: #{e.message}")
        rescue StandardError => e
            log_error("Unexpected error: #{e.message}")
        end

        private

        def retrieve_checkout_session
            Stripe::Checkout::Session.retrieve({
                id: @id,
                expand: ['line_items']
            })
        end

        def invalid_checkout_session?(checkout_session)
            if not_paid?(checkout_session)
                puts "Skipping checkout session #{@id} because it's not paid"
                return true
            elsif checkout_session.customer_details&.email.nil?
                puts "Skipping checkout session #{@id} because it has no email"
                return true
            end
            false
        end

        def not_paid?(checkout_session)
            checkout_session.payment_status != 'paid'
        end

        def find_or_create_user(email)
            EmailAuth::FindsOrCreatesUser.new(email: email).call
        end

        def update_user_plan(user, purchased_items)
            purchased_items.each do |item|
                plan_type = PLAN_TYPES[item.price.product]
                user.update(plan: plan_type) if plan_type
            end
        end

        def log_error(message)
            # Replace this with your preferred error logging method
            puts message
        end
    end
end