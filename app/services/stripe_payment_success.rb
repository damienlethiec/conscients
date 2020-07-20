# frozen_string_literal: true

class StripePaymentSuccess
  def self.call(cart, event_params)
    new(cart, event_params).call
  end

  def initialize(cart, event_params)
    @cart = cart
    @event_params = event_params
  end

  def call
    return unless @cart.in_cart?

    @cart.stripe!
    @cart.update(payment_details: charge)
    @cart.pay!
  end

  private

  def paid?
    @event_params['status'] == 'succeeded'
  end

  def charge
    @event_params['charges']['data'].first.to_json
  end
end
