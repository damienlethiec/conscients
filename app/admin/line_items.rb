# frozen_string_literal: true

ActiveAdmin.register LineItem do
  menu parent: I18n.t('active_admin.order_management')

  permit_params :product_sku_id, :order_id, :ttc_price_cents, :ttc_price_currency,
                :tree_plantation_id, :quantity, :recipient_name, :recipient_message,
                :certificate_date, :certificate_number, :delivery_email

  index do
     column :id
     column :product_sku
     column :order
     column :order_id
     column :ttc_price_cents
     column :ttc_price_currency
     column :ht_price_cents
     column :ht_price_currency
     column :tree_plantation
     column :quantity
     column :recipient_name
     column :recipient_message
     column :certificate_date
     column :certificate_number
     column :delivery_email
     column :created_at
     column :updated_at
     actions
  end

  csv do
    column :id
    column :created_at
    column :updated_at
    column :product_sku_id
    column :product_sku
    column :payment_method
    column :order_id
    column :client_id
    column :client_email do |line_item|
      line_item.order.client.email
    end
    column :country do |line_item|
      line_item.order&.delivery_address&.country
    end
    column :quantity
    column :ht_price_cents
    column :ht_price_currency
    column :ttc_price_cents
    column :ttc_price_currency
    column :delivery_fees_cents
    column :tree_plantation_id
    column :recipient_name
    column :certificate_date
    column :certificate_number
    column :delivery_email
  end

  # Custom action --> Link + simili controller
  action_item :download_certificate, only: :show, if: proc { line_item.certificate.attached? } do
    link_to t('.download_certificate'),
            download_certificate_admin_line_item_path(line_item), method: :put
  end

  member_action :download_certificate, method: :put do
    send_data(resource.certificate.download, disposition: 'attachment',
              filename: "certificate##{resource.id}")
  end
end
