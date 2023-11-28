class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!

    def create
        payload = request.body.read
        event = nil
        endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

        begin
            event = Stripe::Event.construct_from(
            JSON.parse(payload, symbolize_names: true)
            )
        rescue JSON::ParserError => e
            # Invalid payload
            status 400
            return
        end

        # Check if webhook signing is configured.
        if endpoint_secret
            # Retrieve the event by verifying the signature using the raw body and secret.
            signature = request.env['HTTP_STRIPE_SIGNATURE'];
            begin
                event = Stripe::Webhook.construct_event(
                    payload, signature, endpoint_secret
                )
            rescue Stripe::SignatureVerificationError => e
                puts "⚠️  Webhook signature verification failed. #{e.message}"
                status 400
            end
        end

        # Handle the event
        case event.type
        when 'checkout.session.completed'
            handle_checkout_session_completed(event)
        else
            puts "Unhandled event type: #{event.type}"
        end

        head 200
    end

    private

    def handle_checkout_session_completed(event)
        Payment::CheckoutSessionCompleted.new(event).call
    end
end
