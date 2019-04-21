# frozen_string_literal: true

ActiveAdmin.register Order do
  menu parent: I18n.t('active_admin.order_management')

  permit_params :active_admin_requested_event, :client_id, :coupon_id, :delivery_address_id,
                :billing_address_id, :delivery_method, :payment_method, :recipient_message,
                :customer_note, :payment_date

  includes :client, :coupon, :delivery_address, :billing_address

  scope :not_in_cart, default: true
  scope :in_cart
  scope :all

  # Custom action --> Link + simili controller
  action_item :download_invoice, only: :show, if: proc { order.invoice.attached? } do
    link_to t('.download_invoice'), download_invoice_admin_order_path(order), method: :put
  end

  member_action :download_invoice, method: :put do
    send_data(resource.invoice.download, disposition: 'attachment',
              filename: "invoice##{resource.id}")
  end

  # Manage state change in admin
  after_save do |order|
    event = params[:order][:active_admin_requested_event]
    if event.present?
      # whitelist to ensure we don't run an arbitrary method
      safe_event = (order.aasm.events(permitted: true).map(&:name) & [event.to_sym]).first
      raise "Forbidden event #{event} requested on instance #{your_model.id}" unless safe_event

      # launch the event with bang
      order.send("#{safe_event}!")
    end
  end

  index do
    selectable_column
    id_column
    column :aasm_state do |order|
      I18n.t("activerecord.attributes.order.aasm_state/#{order.aasm_state}")
    end
    # column :coupon_id
    # column :delivery_address_id do |order|
    #   order.delivery_address.to_s
    # end
    # column :billing_address_id do |order|
    #   order.billing_address.to_s
    # end
    # column :delivery_method
    # column :delivery_fees_cents
    # column :delivery_fees_currency
    column :total_price_cents
    # column :total_price_currency
    column :payment_method
    # column :recipient_message
    # column :customer_note
    column :payment_date
    column :client_id
    column :created_at
    # column :updated_at
    # column :payment_details
    actions
  end

  form do |f|
    f.semantic_errors
    inputs do
      # display current state as disabled to avoid modifying it directly
      f.input :aasm_state, input_html: { disabled: true },
              label: I18n.t('active_admin.current_state')
      # use the attr_accessor to pass the data
      f.input :active_admin_requested_event, label: I18n.t('active_admin.change_state'),
              as: :select, collection: f.object.translated_hash_permitted_events
      f.input :client
      f.input :coupon
      f.input :delivery_address, as: :select, selected: f.object.delivery_address.id,
              collection: f.object.client_addresses&.collect { |a| [a.to_s, a.id] }
      f.input :billing_address, as: :select, selected: f.object.billing_address.id,
              collection: f.object.client_addresses&.collect { |a| [a.to_s, a.id] }
      f.input :delivery_method
      f.input :payment_method
      f.input :recipient_message
      f.input :customer_note
      f.input :payment_date
    end
    f.actions
  end
end
