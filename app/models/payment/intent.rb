# frozen_string_literal: true

module Payment
  class Intent
    def self.fetch(cart)
      new(cart).fetch
    end

    def initialize(cart)
      @cart = cart
      Stripe.api_key = stripe_secret_key
    end

    def fetch
      CreateStripePaymentIntent.new(@cart).perform unless @cart.payment_intent_id
      payment_intent
    end

    private

    def payment_intent
      Stripe::PaymentIntent.retrieve(@cart.payment_intent_id)
    end

    def stripe_secret_key
      Rails.application.credentials.dig(Rails.env.to_sym, :stripe_secret_key)
    end
  end
end
