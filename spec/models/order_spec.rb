# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id                     :bigint(8)        not null, primary key
#  aasm_state             :integer          not null
#  coupon_id              :bigint(8)
#  delivery_address_id    :bigint(8)
#  billing_address_id     :bigint(8)
#  delivery_method        :integer          default("postal"), not null
#  delivery_fees_cents    :integer          default(0), not null
#  delivery_fees_currency :string           default("EUR"), not null
#  total_price_cents      :integer          default(0), not null
#  total_price_currency   :string           default("EUR"), not null
#  payment_method         :integer          default("stripe"), not null
#  recipient_message      :text
#  customer_note          :text
#  payment_date           :datetime
#  client_id              :bigint(8)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  payment_details        :jsonb
#
# Foreign Keys
#
#  fk_rails_...  (billing_address_id => addresses.id)
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (coupon_id => coupons.id)
#  fk_rails_...  (delivery_address_id => addresses.id)
#

require 'rails_helper'

RSpec.describe Order, type: :model do
  context 'generally' do
    it 'has a default status of in-cart' do
      order = build(:order)
      expect(order.aasm_state).to eq('in_cart')
    end

    it 'transitions from to status waiting_for_bank_transfer when order_by_bank_transfer!' do
      order = build(:order)
      order.order_by_bank_transfer!
      expect(order.aasm_state).to eq('waiting_for_bank_transfer')
    end
  end

  context '#current_delivery_fees_cents' do
    it 'returns 13.5 euros in shipping costs to France when a user purchases 10 trees' do
      # build order
      order = build(:order,
        aasm_state: "preparing",
        delivery_method: "postal")

      # build product
      product = build(:product,
        product_type: "tree",
        weight: 50)

      # build tree_plantation
      tree_plantation = build(:tree_plantation)
      # associate tree_plantation and product
      # product_tree_plantation(tree_plantation: tree_plantation, product: product)

      # buld product_sku
      product_sku = build(:product_sku,
        product: product,
        quantity: 10)


      # build variant?

      # build line_item
      line_item = build(:line_item,
                                quantity: 10,
                                product_sku: product_sku,
                                tree_plantation: tree_plantation)
      order.line_items << line_item
      line_item.product == product
      # line_item.product_sku == product_sku
      # binding.pry
      expect(order.current_delivery_fees_cents).to eq(1350)
    end

    # A user who purchases 1 tree should be charged 4.8 euros in shipping costs to France

    # A user who purchases 1 classic product weighing 500 grams should be charged 5.5 euros in shipping costs to France

    # A user who purchases 10 classic products weighing 500 grams each should be charged 13.5 euros in shipping costs to France
  end
end

