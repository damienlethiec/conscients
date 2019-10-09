# frozen_string_literal: true

class Webhooks::Stripe::EventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def payment_intent_succeeded
    cart = Order.find_by payment_intent_id: event_params['id']
    StripePaymentSuccess.call(cart, event_params)
    head :ok
  end

  private

  def event_params
    @event_params ||= params['data']['object']
  end
end
