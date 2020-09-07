# frozen_string_literal: true

class Paypal::Order::Capture < Paypal::Order::Base
  def self.call(args = {})
    new(args).call
  end

  def initialize(params = {})
    @order_id = params[:order_id] || 1001
  end

  def call
    return failed unless valid_request

    begin
      response = client.execute(request)
      order = response.result
    rescue PayPalHttp::HttpError => ioe
      { status_code: ioe.status_code, debug_id: ioe.headers["debug_id"] }
    end
  end

  private
  def request
    PayPalCheckoutSdk::Orders::OrdersCaptureRequest::new(@order_id)
  end

  def valid_request
    order_id.present?
  end

  def order_id
    binding.pry
    @cart.payment_details
  end
end
