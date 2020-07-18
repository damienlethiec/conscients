# frozen_string_literal: true

class Checkout::PaymentsController < ApplicationController
  before_action :cancel_stripe_payment_intent, only: %i[create_paypal
                                                        create_bank_transfer paypal_success]

  def new
    redirect_to(cart_path(@cart)) && return if @cart.ht_price_cents.zero?

    @intent = intent
  end

  def stripe_success
    @cart.stripe!
    @cart.pay!
    @cart.save
    redirect_to payment_path(@cart)
  end

  def create_paypal
    redirect_url = CreatePaypalPayment.new(@cart).perform_creation
    redirect_to redirect_url
  rescue PayPalError
    redirect_to new_payment_path, alert: t('flash.payments.create.alert')
  end

  def create_bank_transfer
    @cart.bank_transfer!
    @cart.order_by_bank_transfer!
    @cart.update(total_price: @cart.ttc_price_all_included)
    ClientMailer.with(order: @cart).bank_account_details.deliver_later
    # redirect_to payment_path(@cart), notice: t('flash.payments.create_bank_transfer.notice')
    redirect_to payment_path(@cart)
  end

  def paypal_success
    CreatePaypalPayment.new(@cart, params).perform_execution
    redirect_to payment_path(@cart), notice: t('flash.payments.create.notice')
  rescue PayPalError
    redirect_to new_payment_path, alert: t('flash.payments.create.alert')
  end

  def show
    @order = Order.find(params[:id])
  end

  def intent
    return Struct.new('PaymentIntent', :client_secret).new if Rails.env.test?

    Payment::Intent.fetch(@cart)
  end
end
