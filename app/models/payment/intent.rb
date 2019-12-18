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
      intent_exists? ? updated_intent : new_intent
    end

    private

    def new_intent
      return if Rails.env.test?

      CreateStripePaymentIntent.new(@cart).perform
    end

    def intent_exists?
      !@cart.payment_intent_id.nil?
    end

    def updated_intent
      Stripe::PaymentIntent.update(
        @cart.payment_intent_id,
        amount: amount,
        metadata: {
          shipping_cents: shipping_cents,
          subtotal_cents: subtotal_cents
        }
      )
    end

    def amount
      @cart.ttc_price_all_included.fractional
    end

    def shipping_cents
      @cart.current_delivery_fees_cents
    end

    def subtotal_cents
      @cart.ttc_price_with_coupon_cents
    end
  end
end
