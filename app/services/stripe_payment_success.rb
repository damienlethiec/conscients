# frozen_string_literal: true

class StripePaymentSuccess
  def self.persist(cart)
    new(cart).persist
  end

  def initialize(cart)
    @cart = cart
    Stripe.api_key = stripe_secret_key
  end

  def persist
    @cart.stripe!
    @cart.update(payment_details: intent.charges.first.to_json)
    @cart.pay!
  end

  private

  def stripe_secret_key
    Rails.application.credentials.dig(Rails.env.to_sym, :stripe_secret_key)
  end

  def intent
    Payment::Intent.fetch(@cart)
  end
end
