# frozen_string_literal: true

class Paypal::Order::Create < Paypal::Order::Base
  def self.call(cart, params = {})
    new(cart, params).call
  end

  def initialize(cart, params)
    @cart = cart
  end

  def call
    return failed unless valid_request

    @cart.update payment_details: response.to_json
    redirect_url
  end

  private

  def redirect_url
    response.result.links.find { |v| v.rel == 'approve' }.href
  end

  def response
    @response ||= client.execute(request)
  end

  def request
    request = PayPalCheckoutSdk::Orders::OrdersCreateRequest::new
    request.request_body(order_create_body)
    request
  end

  def order_create_body
    {
      intent: "CAPTURE",
      purchase_units: [{
        amount: {
          currency_code: currency_code,
          value: @cart.ttc_price_all_included.dollars
        }
      }]
    }
  end

  def valid_request
    @cart.ttc_price_all_included.dollars.positive?
  end
end
