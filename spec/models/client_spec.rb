# frozen_string_literal: true
# == Schema Information
#
# Table name: clients
#
#  id                     :bigint(8)        not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  first_name             :string
#  last_name              :string
#  phone_number           :string
#  newsletter_subscriber  :boolean          default(TRUE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  provider               :string
#  uid                    :string
#  stripe_customer_id     :string
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_type        :string
#  invited_by_id          :bigint(8)
#  invitations_count      :integer          default(0)
#  can_debug              :boolean          default(FALSE), not null
#  session_token          :string           default("3a3f286bca8e58c0a369556b3c362bba")
#

require 'rails_helper'

RSpec.describe Order, type: :model do
  # context 'A user' do
  #   it 'can update his password' do
  #     client = FactoryBot.create(:client, email: 'new@gmail.com', password: 'password')
  #     update_with_password(client, {current_password: 'password', password: 'newpassword'})
  #     expect(client.valid_password?('newpassword')).to be true
  #   end

  #   it 'can not update his password if his current_password is wrong' do
  #     client = FactoryBot.create(:client, email: 'new@gmail.com', password: 'password')
  #     update_with_password(client, {current_password: 'random', password: 'newpassword'})
  #     expect(client.valid_password?('newpassword')).to be false
  #   end
  # end

  # def update_with_password(client, params)
  #   current_password = params.delete(:current_password)

  #   if params[:password].blank?
  #     params.delete(:password)
  #     params.delete(:password_confirmation) if params[:password_confirmation].blank?
  #   end

  #   result = if params[:password].blank?
  #     false
  #   elsif client.valid_password?(current_password)
  #     result = client.update(password: params[:password])
  #     # bypass_sign_in(client)
  #     result
  #   else
  #     client.assign_attributes(password: params[:password])
  #     # bypass_sign_in(client)
  #     client.valid?
  #     client.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
  #     false
  #   end

  #   params.delete(:password)
  #   result
  # end
end
