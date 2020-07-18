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
#  payment_intent_id      :string
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
    it 'returns  4.80 euros in shipping costs to France when a user purchases 1 tree product with a quantity of 1 - 1 certificate' do
      client = Client.create!(email: 'test@gmail.com', password: '12345678')
      order = Order.create!(client: client)

      product = Product.create!(
        name_fr: 'Arbre',
        weight: 50,
        name_en: 'Top Tree',
        description_short: "Un arbre qui vaut vraiment le coup et que tout\
        # le monde devrait acheter parce qu'il est vraiment bien",
        ht_price_cents: 500,
        product_type: 2,
        ht_buying_price_cents: 400,
        seo_title: 'Super Top arbre',
        color_certificate: '#ff0000',
        meta_description: "Un arbre qui vaut vraiment le coup et que tout\
        # le monde devrait acheter parce qu'il est vraiment bien"
      )

      tree_plantation = TreePlantation.create!(
        project_name: 'Alta Huayabamba, San Martin, Pérou',
        project_type_fr: 'reforestation / agroforesterie',
        project_type_en: 'some tree stuff',
        partner: 'Fundacion Amazonia Viva',
        plantation_uuid: SecureRandom.uuid,
        tree_specie: 'capirona, boleina',
        producer_name: 'Eber Vaqui Saldana',
        trees_quantity: 100,
        base_certificate_uuid: SecureRandom.uuid.slice(0, 10),
        latitude: -13.524001,
        longitude: -72.007402
      )

      ProductTreePlantation.create!(tree_plantation: tree_plantation, product: product)

      product_sku = ProductSku.create!(product: product)

      line_item_params = {
        'recipient_name': 'Kristian', 'recipient_message': 'Test',
        'certificate_date': Time.zone.today.strftime('%F'),
        'product_sku_id': product_sku.id
      }

      line_item = AddItemToCart.new(order, line_item_params, 1).perform
      line_item.save!

      order.postal!

      Address.create!(
        client: client,
        first_name: 'test',
        last_name: 'test',
        address_1: 'test',
        country: 'FR',
        zip_code: '200',
        city: 'CPH'
      )

      order_params = { recipient_message: '', customer_note: '' }

      addresses_params = {
        delivery_is_billing: '1', address_type: 'postal',
        delivery_address: { first_name: 'K', last_name: 'S', company: '', address_1: 'T 32',
           address_2: '', city: 'Frederiksberg', zip_code: '2000', country: 'FR' },
        billing_address: { first_name: 'K', last_name: 'Sølling', company: '', address_1: 'T 32',
          address_2: '', city: 'Frederiksberg', zip_code: '2000', country: 'FR' }
      }

      order, _delivery_address, _billing_address =
        LinkDeliveryInfoToCart.new(order, order_params, addresses_params).perform

      expect(order.current_delivery_fees_cents).to eq(480)
    end

    it 'returns  4.80 euros in shipping costs to France when a user purchases 1 tree product with a quantity of 10 - 1 certificate' do
      client = Client.create!(email: 'test@gmail.com', password: '12345678')
      order = Order.create!(client: client)

      product = Product.create!(
        name_fr: 'Arbre',
        weight: 50,
        name_en: 'Top Tree',
        description_short: "Un arbre qui vaut vraiment le coup et que tout\
        # le monde devrait acheter parce qu'il est vraiment bien",
        ht_price_cents: 500,
        product_type: 2,
        ht_buying_price_cents: 400,
        seo_title: 'Super Top arbre',
        color_certificate: '#ff0000',
        meta_description: "Un arbre qui vaut vraiment le coup et que tout\
        # le monde devrait acheter parce qu'il est vraiment bien"
      )

      tree_plantation = TreePlantation.create!(
        project_name: 'Alta Huayabamba, San Martin, Pérou',
        project_type_fr: 'reforestation / agroforesterie',
        project_type_en: 'some tree stuff',
        partner: 'Fundacion Amazonia Viva',
        plantation_uuid: SecureRandom.uuid,
        tree_specie: 'capirona, boleina',
        producer_name: 'Eber Vaqui Saldana',
        trees_quantity: 100,
        base_certificate_uuid: SecureRandom.uuid.slice(0, 10),
        latitude: -13.524001,
        longitude: -72.007402
      )

      ProductTreePlantation.create!(tree_plantation: tree_plantation, product: product)

      product_sku = ProductSku.create!(product: product)

      line_item_params = {
        'recipient_name': 'Kristian', 'recipient_message': 'Test',
        'certificate_date': Time.zone.today.strftime('%F'),
        'product_sku_id': product_sku.id
      }

      line_item = AddItemToCart.new(order, line_item_params, 10).perform
      line_item.save!

      order.postal!

      Address.create!(
        client: client,
        first_name: 'test',
        last_name: 'test',
        address_1: 'test',
        country: 'FR',
        zip_code: '200',
        city: 'CPH'
      )

      order_params = { recipient_message: '', customer_note: '' }

      addresses_params = {
        delivery_is_billing: '1', address_type: 'postal',
        delivery_address: { first_name: 'K', last_name: 'S', company: '', address_1: 'T 32',
           address_2: '', city: 'Frederiksberg', zip_code: '2000', country: 'FR' },
        billing_address: { first_name: 'K', last_name: 'Sølling', company: '', address_1: 'T 32',
          address_2: '', city: 'Frederiksberg', zip_code: '2000', country: 'FR' }
      }

      order, _delivery_address, _billing_address =
        LinkDeliveryInfoToCart.new(order, order_params, addresses_params).perform

      expect(order.current_delivery_fees_cents).to eq(480)
    end

    it 'returns  8.00 euros in shipping costs to France when a user purchases 5 separate tree products of unknown quantities - 5 certificates' do
      client = Client.create!(email: 'test@gmail.com', password: '12345678')
      order = Order.create!(client: client)

      5.times do |idx|
        product = Product.create!(
          id: idx,
          name_fr: "Arbre#{idx}",
          weight: 50,
          name_en: "Top Tree#{idx}",
          description_short: "Un arbre qui vaut vraiment le coup et que tout\
          # le monde devrait acheter parce qu'il est vraiment bien",
          ht_price_cents: 500,
          product_type: 2,
          ht_buying_price_cents: 400,
          seo_title: "Super Top arbre#{idx}",
          color_certificate: '#ff0000',
          meta_description: "Un arbre qui vaut vraiment le coup et que tout\
          # le monde devrait acheter parce qu'il est vraiment bien"
        )

        tree_plantation = TreePlantation.create!(
          id: idx,
          project_name: "tree_plantation#{idx}",
          project_type_fr: 'reforestation / agroforesterie',
          project_type_en: 'some tree stuff',
          partner: 'Fundacion Amazonia Viva',
          plantation_uuid: SecureRandom.uuid,
          tree_specie: 'capirona, boleina',
          producer_name: 'Eber Vaqui Saldana',
          trees_quantity: 100,
          base_certificate_uuid: SecureRandom.uuid.slice(0, 10),
          latitude: -13.524001,
          longitude: -72.007402
        )

        ProductTreePlantation.create!(tree_plantation: tree_plantation, product: product)

        product_sku = ProductSku.create!(product: product)

        line_item_params = {
          'recipient_name': 'Kristian', 'recipient_message': 'Test',
          'certificate_date': Time.zone.today.strftime('%F'),
          'product_sku_id': product_sku.id
        }

        line_item = AddItemToCart.new(order, line_item_params, 10).perform
        line_item.save!
      end

      order.postal!

      Address.create!(
        client: client,
        first_name: 'test',
        last_name: 'test',
        address_1: 'test',
        country: 'FR',
        zip_code: '200',
        city: 'CPH'
      )

      order_params = { recipient_message: '', customer_note: '' }

      addresses_params = {
        delivery_is_billing: '1', address_type: 'postal',
        delivery_address: { first_name: 'K', last_name: 'S', company: '', address_1: 'T 32',
           address_2: '', city: 'Frederiksberg', zip_code: '2000', country: 'FR' },
        billing_address: { first_name: 'K', last_name: 'Sølling', company: '', address_1: 'T 32',
          address_2: '', city: 'Frederiksberg', zip_code: '2000', country: 'FR' }
      }

      order, _delivery_address, _billing_address =
        LinkDeliveryInfoToCart.new(order, order_params, addresses_params).perform

      expect(order.current_delivery_fees_cents).to eq(800)
    end

    it 'returns 13.50 euros in shipping costs to France when a user purchases 10 separate tree products of unknown quantities - 10 certificates' do
      client = Client.create!(email: 'test@gmail.com', password: '12345678')
      order = Order.create!(client: client)

      10.times do |idx|
        product = Product.create!(
          id: idx,
          name_fr: "Arbre#{idx}",
          weight: 50,
          name_en: "Top Tree#{idx}",
          description_short: "Un arbre qui vaut vraiment le coup et que tout\
          # le monde devrait acheter parce qu'il est vraiment bien",
          ht_price_cents: 500,
          product_type: 2,
          ht_buying_price_cents: 400,
          seo_title: "Super Top arbre#{idx}",
          color_certificate: '#ff0000',
          meta_description: "Un arbre qui vaut vraiment le coup et que tout\
          # le monde devrait acheter parce qu'il est vraiment bien"
        )

        tree_plantation = TreePlantation.create!(
          id: idx,
          project_name: "tree_plantation#{idx}",
          project_type_fr: 'reforestation / agroforesterie',
          project_type_en: 'some tree stuff',
          partner: 'Fundacion Amazonia Viva',
          plantation_uuid: SecureRandom.uuid,
          tree_specie: 'capirona, boleina',
          producer_name: 'Eber Vaqui Saldana',
          trees_quantity: 100,
          base_certificate_uuid: SecureRandom.uuid.slice(0, 10),
          latitude: -13.524001,
          longitude: -72.007402
        )

        ProductTreePlantation.create!(tree_plantation: tree_plantation, product: product)

        product_sku = ProductSku.create!(product: product)

        line_item_params = {
          'recipient_name': 'Kristian', 'recipient_message': 'Test',
          'certificate_date': Time.zone.today.strftime('%F'),
          'product_sku_id': product_sku.id
        }

        line_item = AddItemToCart.new(order, line_item_params, 10).perform
        line_item.save!
      end

      order.postal!

      Address.create!(
        client: client,
        first_name: 'test',
        last_name: 'test',
        address_1: 'test',
        country: 'FR',
        zip_code: '200',
        city: 'CPH'
      )

      order_params = { recipient_message: '', customer_note: '' }

      addresses_params = {
        delivery_is_billing: '1', address_type: 'postal',
        delivery_address: { first_name: 'K', last_name: 'S', company: '', address_1: 'T 32',
           address_2: '', city: 'Frederiksberg', zip_code: '2000', country: 'FR' },
        billing_address: { first_name: 'K', last_name: 'Sølling', company: '', address_1: 'T 32',
          address_2: '', city: 'Frederiksberg', zip_code: '2000', country: 'FR' }
      }

      order, _delivery_address, _billing_address =
        LinkDeliveryInfoToCart.new(order, order_params, addresses_params).perform

      expect(order.current_delivery_fees_cents).to eq(1350)
    end

    it 'returns  9.00 euros in shipping costs to France when a user purchases 3 classic product with a total weight of 1500 grams' do
      client = Client.create!(email: 'test@gmail.com', password: '12345678')
      order = Order.create!(client: client)

      product = Product.create!(
        name_fr: 'Classic',
        weight: 500,
        name_en: 'Top Classic',
        description_short: "Un arbre qui vaut vraiment le coup et que tout\
        # le monde devrait acheter parce qu'il est vraiment bien",
        ht_price_cents: 1200,
        product_type: 0,
        ht_buying_price_cents: 1000,
        seo_title: 'Super Top classic',
        color_certificate: '#ff0000',
        meta_description: "Un arbre qui vaut vraiment le coup et que tout\
        # le monde devrait acheter parce qu'il est vraiment bien"
      )

      product_sku = ProductSku.create!(product: product)
      StockEntry.create!(product_sku: product_sku, quantity: 100)

      line_item_params = {
        'product_sku_id': product_sku.id
      }

      line_item = AddItemToCart.new(order, line_item_params, 3).perform
      line_item.save!

      order.postal!

      Address.create!(
        client: client,
        first_name: 'test',
        last_name: 'test',
        address_1: 'test',
        country: 'FR',
        zip_code: '200',
        city: 'CPH'
      )

      order_params = { recipient_message: '', customer_note: '' }

      addresses_params = {
        delivery_is_billing: '1', address_type: 'postal',
        delivery_address: { first_name: 'K', last_name: 'S', company: '', address_1: 'T 32',
           address_2: '', city: 'Frederiksberg', zip_code: '2000', country: 'FR' },
        billing_address: { first_name: 'K', last_name: 'Sølling', company: '', address_1: 'T 32',
          address_2: '', city: 'Frederiksberg', zip_code: '2000', country: 'FR' }
      }

      order, _delivery_address, _billing_address =
        LinkDeliveryInfoToCart.new(order, order_params, addresses_params).perform

      expect(order.current_delivery_fees_cents).to eq(900)
    end

    it 'returns  9.80 euros in shipping costs to France when a user purchases 3 classic product with a total weight of 1500 grams, and 1 tree product with an unknown quantity - 1 certificate' do
      client = Client.create!(email: 'test@gmail.com', password: '12345678')
      order = Order.create!(client: client)

      product_classic = Product.create!(
        name_fr: 'Classic',
        weight: 500,
        name_en: 'Top Classic',
        description_short: "Un arbre qui vaut vraiment le coup et que tout\
        # le monde devrait acheter parce qu'il est vraiment bien",
        ht_price_cents: 1200,
        product_type: 0,
        ht_buying_price_cents: 1000,
        seo_title: 'Super Top classic',
        color_certificate: '#ff0000',
        meta_description: "Un arbre qui vaut vraiment le coup et que tout\
        # le monde devrait acheter parce qu'il est vraiment bien"
      )

      product_classic_sku = ProductSku.create!(product: product_classic)
      StockEntry.create!(product_sku: product_classic_sku, quantity: 100)

      line_item_classic_params = {
        'product_sku_id': product_classic_sku.id
      }

      line_item_classic = AddItemToCart.new(order, line_item_classic_params, 3).perform
      line_item_classic.save!

      Address.create!(
        client: client,
        first_name: 'test',
        last_name: 'test',
        address_1: 'test',
        country: 'FR',
        zip_code: '200',
        city: 'CPH'
      )

      order_params = { recipient_message: '', customer_note: '' }

      addresses_params = {
        delivery_is_billing: '1', address_type: 'postal',
        delivery_address: { first_name: 'K', last_name: 'S', company: '', address_1: 'T 32',
           address_2: '', city: 'Frederiksberg', zip_code: '2000', country: 'FR' },
        billing_address: { first_name: 'K', last_name: 'Sølling', company: '', address_1: 'T 32',
          address_2: '', city: 'Frederiksberg', zip_code: '2000', country: 'FR' }
      }

      order, _delivery_address, _billing_address =
        LinkDeliveryInfoToCart.new(order, order_params, addresses_params).perform

      product_tree = Product.create!(
        name_fr: 'Arbre',
        weight: 50,
        name_en: 'Top Tree',
        description_short: "Un arbre qui vaut vraiment le coup et que tout\
        # le monde devrait acheter parce qu'il est vraiment bien",
        ht_price_cents: 500,
        product_type: 2,
        ht_buying_price_cents: 400,
        seo_title: 'Super Top arbre',
        color_certificate: '#ff0000',
        meta_description: "Un arbre qui vaut vraiment le coup et que tout\
        # le monde devrait acheter parce qu'il est vraiment bien"
      )

      tree_plantation = TreePlantation.create!(
        project_name: 'Alta Huayabamba, San Martin, Pérou',
        project_type_fr: 'reforestation / agroforesterie',
        project_type_en: 'some tree stuff',
        partner: 'Fundacion Amazonia Viva',
        plantation_uuid: SecureRandom.uuid,
        tree_specie: 'capirona, boleina',
        producer_name: 'Eber Vaqui Saldana',
        trees_quantity: 100,
        base_certificate_uuid: SecureRandom.uuid.slice(0, 10),
        latitude: -13.524001,
        longitude: -72.007402
      )

      ProductTreePlantation.create!(tree_plantation: tree_plantation, product: product_tree)

      product_tree_sku = ProductSku.create!(product: product_tree)

      line_item_tree_params = {
        'recipient_name': 'Kristian', 'recipient_message': 'Test',
        'certificate_date': Time.zone.today.strftime('%F'),
        'product_sku_id': product_tree_sku.id
      }

      line_item_tree = AddItemToCart.new(order, line_item_tree_params, 10).perform
      line_item_tree.save!

      order.postal!

      Address.create!(
        client: client,
        first_name: 'test',
        last_name: 'test',
        address_1: 'test',
        country: 'FR',
        zip_code: '200',
        city: 'CPH'
      )

      order_params = { recipient_message: '', customer_note: '' }

      addresses_params = {
        delivery_is_billing: '1', address_type: 'postal',
        delivery_address: { first_name: 'K', last_name: 'S', company: '', address_1: 'T 32',
           address_2: '', city: 'Frederiksberg', zip_code: '2000', country: 'FR' },
        billing_address: { first_name: 'K', last_name: 'Sølling', company: '', address_1: 'T 32',
          address_2: '', city: 'Frederiksberg', zip_code: '2000', country: 'FR' }
      }

      order, _delivery_address, _billing_address =
        LinkDeliveryInfoToCart.new(order, order_params, addresses_params).perform

      expect(order.current_delivery_fees_cents).to eq(980)
    end
  end
end
