# frozen_string_literal: true

# Check if there is no problem as does not really work for Carole
Rails.logger = Logger.new(STDOUT)

task create_development_resources: :environment do
  desc 'Create minimal resources to allow tests in development'

  Rails.logger.info 'models destruction start'

  StockEntry.delete_all
  Product.destroy_all
  AdminUser.destroy_all
  Categorization.destroy_all
  ProductSku.destroy_all
  Client.destroy_all
  Address.destroy_all
  Coupon.destroy_all
  Order.destroy_all
  LineItem.destroy_all
  TreePlantation.destroy_all

  Rails.logger.info 'models destruction end'

  product = Product.create!(
    name_fr: 'Top livre',
    name_en: 'Top book',
    description_short: "Un top livre qui vaut vraiment le coup et que tout\
    le monde devrait lire parce qu'il est vraiment bien",
    ht_price_cents: 1000,
    weight: 1000,
    ht_buying_price_cents: 900,
    seo_title: 'Super Top Livre',
    meta_description: "Un top livre qui vaut vraiment le coup et que tout\
    le monde devrait lire parce qu'il est vraiment bien",
    keywords: %w[top livre]
  )
  ProductSku.create!(product: product)

  product = Product.create!(
    name_fr: 'Top livre 2',
    name_en: 'Top book 2',
    description_short: "Un deuxième top livre qui vaut vraiment le coup et que tout\
    le monde devrait lire parce qu'il est vraiment bien",
    ht_price_cents: 1000,
    weight: 1000,
    ht_buying_price_cents: 900,
    seo_title: 'Top Livre 2',
    meta_description: "Un deuxième top livre qui vaut vraiment le coup et que tout\
    le monde devrait lire parce qu'il est vraiment bien",
    keywords: %w[top livre]
  )
  ProductSku.create!(product: product)

  product = Product.create!(
    name_fr: 'Top vêtement garçon',
    name_en: 'Great boy cloth',
    description_short: "Un top vetement garçon qui vaut vraiment le coup et que tout\
    le monde devrait porter parce qu'il est vraiment bien",
    ht_price_cents: 1200,
    weight: 500,
    ht_buying_price_cents: 1000,
    seo_title: 'Top vetement garçon',
    meta_description: "Un top vetement garçon qui vaut vraiment le coup et que tout\
    le monde devrait porter parce qu'il est vraiment bien",
    keywords: %w[top vetement garçon]
  )
  product_sku = ProductSku.create!(product: product)
  product_sku.update(variant: Variant.find_by(value: '0 à 3 mois'))
  product_sku = ProductSku.create!(product: product)
  product_sku.update(variant: Variant.find_by(value: '3 à 6 mois'))
  product_sku = ProductSku.create!(product: product)
  product_sku.update(variant: Variant.find_by(value: '6 à 12 mois'))

  product = Product.create!(
    name_fr: 'Top vêtement fille',
    name_en: 'Great girl cloth',
    description_short: "Un top vetement fille qui vaut vraiment le coup et que tout\
    le monde devrait porter parce qu'il est vraiment bien",
    ht_price_cents: 1200,
    weight: 500,
    ht_buying_price_cents: 1000,
    seo_title: 'Top vetement fille',
    meta_description: "Un top vetement fille qui vaut vraiment le coup et que tout\
    le monde devrait porter parce qu'il est vraiment bien",
    keywords: %w[top vetement fille]
  )
  product_sku = ProductSku.create!(product: product)
  product_sku.update(variant: Variant.find_by(value: '0 à 3 mois'))
  product_sku = ProductSku.create!(product: product)
  product_sku.update(variant: Variant.find_by(value: '3 à 6 mois'))
  product_sku = ProductSku.create!(product: product)
  product_sku.update(variant: Variant.find_by(value: '6 à 12 mois'))

  product = Product.create!(
    name_fr: 'Livre et arbre',
    name_en: 'Book and tree',
    description_short: "Un top bundle livre + arbre qui vaut vraiment le coup et que tout\
    le monde devrait acheter parce qu'il est vraiment bien",
    ht_price_cents: 1700,
    weight: 1000,
    product_type: 1,
    ht_buying_price_cents: 1300,
    seo_title: 'Top bundle livre + arbre',
    meta_description: "Un top bundle livre + arbrequi vaut vraiment le coup et que tout\
    le monde devrait acheter parce qu'il est vraiment bien",
    keywords: %w[top bundle livre arbre]
  )

  file = File.open('lib/assets/certificate-background.jpg')
  product.images.attach \
    io: file,
    filename: 'certificate-background.jpg',
    content_type: 'image/jpg'
  file.close

  file = File.open('lib/assets/certificate-background.jpg')
  product.certificate_background.attach \
    io: file,
    filename: 'certificate-background.jpg',
    content_type: 'image/jpg'
  file.close

  ProductSku.create!(product: product)

  product = Product.create!(
    name_fr: 'Arbre',
    name_en: 'Top Tree',
    description_short: "Un arbre qui vaut vraiment le coup et que tout\
    le monde devrait acheter parce qu'il est vraiment bien",
    ht_price_cents: 500,
    product_type: 2,
    ht_buying_price_cents: 400,
    seo_title: 'Super Top arbre',
    color_certificate: '#ff0000',
    meta_description: "Un arbre qui vaut vraiment le coup et que tout\
    le monde devrait acheter parce qu'il est vraiment bien",
    keywords: %w[top bundle livre arbre]
  )

  file = File.open('lib/assets/certificate-background.jpg')
  product.images.attach \
    io: file,
    filename: 'certificate-background.jpg',
    content_type: 'image/jpg'
  file.close

  file = File.open('lib/assets/certificate-background.jpg')
  product.certificate_background.attach \
    io: file,
    filename: 'certificate-background.jpg',
    content_type: 'image/jpg'
  file.close

  ProductSku.create!(product: product)

  Rails.logger.info 'associate image to all products'
  Product.all.each do |p|
    bg_file = File.open('lib/assets/certificate-background.jpg')
    p.images.attach(io: bg_file, filename: 'tree.jpeg', content_type: 'image/jpeg')
    bg_file.close

    bg_file = File.open('lib/assets/certificate-background.jpg')
    p.background_image.attach(io: bg_file, filename: 'tree.jpeg', content_type: 'image/jpeg')
    bg_file.close

    book_file = File.open('lib/assets/book.jpeg')
    p.images.attach(io: book_file, filename: 'book.jpeg', content_type: 'image/jpeg')
    book_file.close

    8.times do
      Categorization.find_or_create_by!(product: p, category: Category.all.sample)
    end
    p.save
  end

  Rails.logger.info 'create 2 stock_entries for each product_sku'
  ProductSku.all.each do |sku|
    2.times { StockEntry.create!(product_sku: sku, quantity: rand(1..10)) }
  end

  Rails.logger.info 'create a TreePlantation'
  TreePlantation.create!(
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

  Rails.logger.info 'create a Coupon'
  Coupon.create!(name: 'MYREDUC', amount_cents: 1000, amount_min_order_cents: 3000,
                 valid_from: Time.zone.today - 2.days, valid_until: Time.zone.today + 20.days)

  Rails.logger.info "#{Product.all.count} products created with SKU and co"

  if Rails.env.development?
    Rails.logger.info 'create AdminUser'
    AdminUser.create!(email: 'admin@example.com', password: 'password',
                      password_confirmation: 'password')
  end
end
