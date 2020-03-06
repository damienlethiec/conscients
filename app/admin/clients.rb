# frozen_string_literal: true

ActiveAdmin.register Client do
  menu parent: I18n.t('active_admin.client_management')

  permit_params :email, :password, :password_confirmation, :first_name, :last_name, :phone_number,
                :newsletter_subscriber

  filter :email
  filter :first_name
  filter :last_name
  filter :phone_number
  filter :stripe_customer_id

  index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    column :phone_number
    column :newsletter_subscriber
    column :created_at
    column :updated_at
    column :provider
    column :uid
    column :stripe_customer_id
    column :sign_in_count
    column :current_sign_in_at
    column :last_sign_in_at
    column :current_sign_in_ip
    column :last_sign_in_ip
    actions
  end

  form do |f|
    f.semantic_errors
    inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :first_name
      f.input :last_name
      f.input :phone_number
      f.input :newsletter_subscriber
    end
    f.actions
  end
end
