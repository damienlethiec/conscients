# frozen_string_literal: true

class Paypal::Order::Base
  private

  def client
    PayPal::PayPalHttpClient.new(environment)
  end

  def environment
    return PayPal::LiveEnvironment.new(client_id, client_secret) if Rails.env.production?

    PayPal::SandboxEnvironment.new(client_id, client_secret)
  end

  def client_id
    Rails.application.credentials.dig(Rails.env.to_sym, :paypal_client_id)
  end

  def client_secret
    Rails.application.credentials.dig(Rails.env.to_sym, :paypal_secret)
  end

  def currency_code
    'EUR'.freeze
  end

  def failed
    { status_code: 422, error: "Invalid params" }
  end
end
