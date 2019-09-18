# frozen_string_literal: true

class CreateStripePaymentIntent
  def initialize(cart)
    @cart = cart
  end

  def perform
    @cart.update payment_intent_id: payment_intent['id']
    payment_intent
  end

  private

  def customer
    if @cart.client_stripe_customer_id
      Stripe::Customer.retrieve(@cart.client_stripe_customer_id)
    else
      new_customer = Stripe::Customer.create(
        description: "Customer for #{@cart.client_email}",
        email:  @cart.client_email
      )
      @cart.client.update(stripe_customer_id: new_customer.id)
      new_customer
    end
  end

  def payment_intent
    @payment_intent ||= Stripe::PaymentIntent.create(
      amount: amount,
      currency: currency,
      payment_method_types: ['card'],
      description: "PaymentIntent for order ##{@cart.id}",
      customer: customer
    )
  end

  def amount
    @cart.ttc_price_all_included.fractional
  end

  def currency
    @cart.total_price_currency.downcase
  end
end
