# frozen_string_literal: true

module Payment
  class Intent
    def self.fetch(cart)
      new(cart).fetch
    end

    def initialize(cart)
      @cart = cart
    end

    def fetch
      @cart.payment_intent_id ? payment_intent : CreateStripePaymentIntent.new(@cart).perform
    end

    private

    def payment_intent
      Stripe::PaymentIntent.retrieve(@cart.payment_intent_id)
    end
  end
end
