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
    elsif stripe_customers_with_client_email.present?
      stripe_customers_with_client_email.first
    else
      create_customer
    end
  end

  def create_customer
    new_customer = Stripe::Customer.create(
      description: "Customer for #{@cart.client_email}",
      email:  @cart.client_email
    )
    @cart.client.update(stripe_customer_id: new_customer.id)
    new_customer
  end

  def payment_intent
    return test_payment_intent if Rails.env.test?

    @payment_intent ||= Stripe::PaymentIntent.create(
      amount: amount,
      currency: currency,
      payment_method_types: ['card'],
      description: "PaymentIntent for order ##{@cart.id}",
      customer: customer,
      metadata: { shipping_cents: shipping_cents, subtotal_cents: subtotal_cents }
    )
  end

  def test_payment_intent
    {
      amount: amount,
      currency: currency,
      payment_method_types: ['card'],
      description: "PaymentIntent for order ##{@cart.id}",
      customer: 'customer_object'
    }
  end

  def stripe_customers_with_client_email
    @stripe_customers_with_client_email ||= Stripe::Customer.list(email: @cart.client_email)
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

  def currency
    @cart.total_price_currency.downcase
  end
end
