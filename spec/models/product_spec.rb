# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id                       :bigint(8)        not null, primary key
#  description_short        :string
#  description_long         :text
#  ht_price_cents           :integer          default(0), not null
#  ht_price_currency        :string           default("EUR"), not null
#  tax_rate                 :decimal(4, 2)    default(20.0), not null
#  weight                   :integer          default(0)
#  product_type             :integer          default("classic"), not null
#  published                :boolean          default(TRUE), not null
#  position                 :integer
#  ht_buying_price_cents    :integer          default(0), not null
#  ht_buying_price_currency :string           default("EUR"), not null
#  seo_title                :string
#  meta_description         :string
#  keywords                 :text             default([]), is an Array
#  slug                     :string
#  producer_latitude        :decimal(11, 8)
#  producer_longitude       :decimal(11, 8)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  name_en                  :string
#  name_fr                  :string
#  position_home            :integer
#  color_certificate        :string
#

require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'in_stock' do
    it 'includes a product.tree? if any of its tree_plantations has stock' do
      product = FactoryBot.create(:product, ht_price_cents: 417,
        product_type: 'tree', color_certificate: '#32B796')
      tp1 = FactoryBot.create(:tree_plantation, trees_quantity: 0)
      FactoryBot.create(:product_tree_plantation,
                        product: product, tree_plantation: tp1)

      expect(Product.in_stock).not_to include product

      tp2 = FactoryBot.create(:tree_plantation,
                              trees_quantity: 10,
                              project_name: 'Argelès sur Forêts',
                              project_type: 'sustainable',
                              partner: 'Les marmottes',
                              latitude: 42.5462,
                              longitude: 3.0229,
                              base_certificate_uuid: 'EKZBV995GHJKV')
      FactoryBot.create(:product_tree_plantation,
                        product: product, tree_plantation: tp2)

      expect(Product.in_stock).to include product
    end

    it 'does not include a product.tree? if none of its tree_plantations has stock' do
      product = FactoryBot.create(:product, ht_price_cents: 417,
        product_type: 'tree', color_certificate: '#32B796')
      tp1 = FactoryBot.create(:tree_plantation, trees_quantity: 0)
      FactoryBot.create(:product_tree_plantation,
                        product: product, tree_plantation: tp1)

      expect(Product.in_stock).not_to include product

      tp2 = FactoryBot.create(:tree_plantation,
                              trees_quantity: 0,
                              project_name: 'Argelès sur Forêts',
                              project_type: 'sustainable',
                              partner: 'Les marmottes',
                              latitude: 42.5462,
                              longitude: 3.0229,
                              base_certificate_uuid: 'EKZBV995GHJKV')

      FactoryBot.create(:product_tree_plantation,
                        product: product, tree_plantation: tp2)

      expect(Product.in_stock).not_to include product
    end

    it 'includes a product.classic? if any of its product_skus has stock' do
      product = FactoryBot.create(:product, ht_price_cents: 417,
        product_type: 'classic')
      FactoryBot.create(:product_sku, product: product, quantity: 0)
      expect(Product.in_stock).not_to include product

      FactoryBot.create(:product_sku, product: product, quantity: 100)
      expect(Product.in_stock).to include product
    end

    it 'does not include a product.classic? if none of its product_skus has stock' do
      product = FactoryBot.create(:product, ht_price_cents: 417,
        product_type: 'classic')
      FactoryBot.create(:product_sku, product: product, quantity: 0)
      expect(Product.in_stock).not_to include product

      FactoryBot.create(:product_sku, product: product, quantity: 0)
      expect(Product.in_stock).not_to include product
    end

    it 'includes a product.personalized? if any of its product_skus has stock' do
      product = FactoryBot.create(:product, ht_price_cents: 417,
        product_type: 'personalized')
      FactoryBot.create(:product_sku, product: product, quantity: 0)
      expect(Product.in_stock).not_to include product

      FactoryBot.create(:product_sku, product: product, quantity: 100)
      expect(Product.in_stock).to include product
    end

    it 'does not include a product.personalized? if none of its product_skus has stock' do
      product = FactoryBot.create(:product, ht_price_cents: 417,
        product_type: 'personalized')
      FactoryBot.create(:product_sku, product: product, quantity: 0)
      expect(Product.in_stock).not_to include product

      FactoryBot.create(:product_sku, product: product, quantity: 0)
      expect(Product.in_stock).not_to include product
    end
  end
end
