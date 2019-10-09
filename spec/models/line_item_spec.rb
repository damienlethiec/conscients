# frozen_string_literal: true

# == Schema Information
#
# Table name: line_items
#
#  id                 :bigint(8)        not null, primary key
#  product_sku_id     :bigint(8)
#  order_id           :bigint(8)
#  ttc_price_cents    :integer          default(0), not null
#  ttc_price_currency :string           default("EUR"), not null
#  ht_price_cents     :integer          default(0), not null
#  ht_price_currency  :string           default("EUR"), not null
#  tree_plantation_id :bigint(8)
#  quantity           :integer          default(0), not null
#  recipient_name     :string
#  recipient_message  :text
#  certificate_date   :date
#  certificate_number :string
#  delivery_email     :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#  fk_rails_...  (product_sku_id => product_skus.id)
#  fk_rails_...  (tree_plantation_id => tree_plantations.id)
#

require 'rails_helper'

RSpec.describe LineItem, type: :model do
  describe 'update_price' do
    it 'handles VAT rounding with quantities > 1' do
      product = FactoryBot.create(:product, ht_price_cents: 417)
      product_sku = FactoryBot.create(:product_sku, product: product, quantity: 100)
      order = FactoryBot.create(:order)
      line_item = FactoryBot.create(:line_item,
                                    quantity: 10,
                                    product_sku: product_sku,
                                    order: order)
      expect(line_item.ttc_price_cents).to eq 5000
    end
  end

  describe 'sufficient_plantation_stock' do
    it 'does not raise an error if the associated tree plantation has stock on create' do
      tree_plantation = FactoryBot.create(:tree_plantation, trees_quantity: 10)
      tree = FactoryBot.create(:product,
                               ht_price_cents: 417,
                               product_type: 'tree',
                               color_certificate: '#ffffff')
      tree_sku = FactoryBot.create(:product_sku, product: tree)
      ProductTreePlantation.create(product: tree, tree_plantation: tree_plantation)
      order = FactoryBot.create(:order)
      line_item = FactoryBot.build(:line_item,
                                   quantity: 8,
                                   product_sku: tree_sku,
                                   order: order,
                                   recipient_name: 'Jon',
                                   certificate_date: Time.zone.today)
      line_item.tree_plantation = line_item.plantation_with_stock
      expect { line_item.save! }.not_to raise_error(ActiveRecord::RecordInvalid)
    end
    it 'raise an error if the associated tree plantation has stock on create' do
      tree_plantation = FactoryBot.create(:tree_plantation, trees_quantity: 10)
      tree = FactoryBot.create(:product,
                               ht_price_cents: 417,
                               product_type: 'tree',
                               color_certificate: '#ffffff')
      tree_sku = FactoryBot.create(:product_sku, product: tree)
      ProductTreePlantation.create(product: tree, tree_plantation: tree_plantation)
      order = FactoryBot.create(:order)
      line_item = FactoryBot.build(:line_item,
                                   quantity: 11,
                                   product_sku: tree_sku,
                                   order: order,
                                   recipient_name: 'Jon',
                                   certificate_date: Time.zone.today)
      line_item.tree_plantation = line_item.plantation_with_stock
      expect { line_item.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'does not raise an error if the associated tree plantation has stock on update' do
      tree_plantation = FactoryBot.create(:tree_plantation, trees_quantity: 10)
      tree = FactoryBot.create(:product,
                               ht_price_cents: 417,
                               product_type: 'tree',
                               color_certificate: '#ffffff')
      tree_sku = FactoryBot.create(:product_sku, product: tree)
      ProductTreePlantation.create(product: tree, tree_plantation: tree_plantation)
      order = FactoryBot.create(:order)
      line_item = FactoryBot.build(:line_item,
                                   quantity: 8,
                                   product_sku: tree_sku,
                                   order: order,
                                   recipient_name: 'Jon',
                                   certificate_date: Time.zone.today)
      line_item.tree_plantation = line_item.plantation_with_stock
      line_item.save
      line_item.quantity = 10

      expect { line_item.save! }.not_to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'raise an error if the associated tree plantation has stock on update' do
      tree_plantation = FactoryBot.create(:tree_plantation, trees_quantity: 10)
      tree = FactoryBot.create(:product,
                               ht_price_cents: 417,
                               product_type: 'tree',
                               color_certificate: '#ffffff')
      tree_sku = FactoryBot.create(:product_sku, product: tree)
      ProductTreePlantation.create(product: tree, tree_plantation: tree_plantation)
      order = FactoryBot.create(:order)

      line_item = FactoryBot.build(:line_item,
                                   quantity: 8,
                                   product_sku: tree_sku,
                                   order: order,
                                   recipient_name: 'Jon',
                                   certificate_date: Time.zone.today)
      line_item.tree_plantation = line_item.plantation_with_stock
      line_item.save

      line_item.quantity = 12

      expect { line_item.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
