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

class LineItem < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :product_sku, autosave: true
  belongs_to :order
  belongs_to :tree_plantation, optional: true, autosave: true
  has_one_attached :certificate

  monetize :ttc_price_cents, :ht_price_cents

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :recipient_name, presence: true, if: :tree_or_personalized?
  validates :recipient_name, length: { maximum: 32 }
  validates :recipient_message, length: { maximum: 110 }
  validates :certificate_date, presence: true, if: :tree_or_personalized?
  validate :sufficient_plantation_stock, if: :tree_or_personalized?

  # Increment and decrement stock quantities
  before_validation :manage_stock_quantites_if_change_sku,
                    :decrement_stock_quantities, prepend: true
  before_destroy :increment_stock_quantities_destroy
  # Calculate price
  before_save :update_price
  # Change the default cart type depending on the products in it
  after_create :set_cart_to_correct_delivery_type
  after_destroy :set_cart_to_correct_delivery_type

  delegate :classic?, :personalized?, :tree?, :tree_or_personalized?, :product,
           :product_images, :product_name, :product_ttc_price_cents, :product_ht_price_cents,
           :product_weight, :certificate_background, :producer_latitude, :producer_longitude,
           :color_certificate, to: :product_sku, allow_nil: true
  delegate :client_full_name, :paid?, :payment_method, :delivery_fees_cents,
           :client_id, to: :order

  delegate :latitude, :longitude, :project_name, :project_type,
           to: :tree_plantation, prefix: true, allow_nil: true

  scope :to_deliver_by_email, -> { where("delivery_email <> ''") }
  scope :certificable, lambda {
    select { |line_item| line_item.tree? || line_item.personalized? }
  }
  scope :certificated, lambda {
    includes(:certificate_attachment).select { |line_item| line_item.certificate.attached? }
  }
  # Order is passed
  scope :finished, lambda {
    includes(:order).where(orders: { aasm_state:
      %w[preparing waiting_for_bank_transfer fulfilled delivered] })
  }
  # Order is passed and paid (not waiting for bank_transfer)
  scope :paid, lambda {
    includes(:order).where(orders: { aasm_state:
      %w[preparing fulfilled delivered] })
  }

  def tree_plantation_marker
    {
      lat: tree_plantation_latitude.to_f,
      lng: tree_plantation_longitude.to_f,
      infoWindow: {
        content: "<h5>#{tree_plantation_project_name}</h5>\
                  #{tree_plantation_project_type}</br>\
                  #{I18n.t('clients.impact.trees_planted_amount',
                           quantity: order_line_items_at_tree_plantation_location_qtty)}"
      },
      icon: ActionController::Base.helpers.asset_path('tree_marker.png')
    }
  end

  def order_line_items_at_tree_plantation_location_qtty
    order_line_items_at_tree_plantation_location.map(&:quantity).sum
  end

  def order_line_items_at_tree_plantation_location
    # some tree_plantations with identical coordinates in production
    order.client
         .line_items
         .joins(:tree_plantation)
         .where(tree_plantations: { latitude: tree_plantation.latitude,
                                    longitude: tree_plantation.longitude })
  end

  def producer_marker
    {
      lat: producer_latitude.to_f,
      lng: producer_longitude.to_f,
      infoWindow: { content: "<h5>#{product_name}</h5>" },
      icon: ActionController::Base.helpers.asset_path('craftstore_marker.png')
    }
  end

  def tree_marker?
    tree_plantation_latitude && tree_plantation_longitude
  end

  def producer_marker?
    producer_latitude && producer_longitude
  end

  # Quantity added during update
  def added_quantity
    quantity - quantity_was
  end

  def update_price
    self.ttc_price_cents = quantity * product_ttc_price_cents.to_i
    self.ht_price_cents = quantity * product_ht_price_cents.to_i
  end

  def generate_certificate(view)
    pdf = WickedPdf.new.pdf_from_string(
      view.render(template: 'certificates/new', layout: 'layouts/pdf',
                   locals: { '@line_item': self,
                             '@background_url': url_certificate },
                   margin: { top: 0, bottom: 0, left: 0, right: 0 }),
      orientation: 'Landscape'
    )
    certificate.attach(io: StringIO.new(pdf),
                                filename: "certificate##{id}.pdf",
                                content_type: 'application/pdf')
  end

  def shipping_weight
    tree? ? product_weight : quantity * product_weight
  end

  def plantation_with_stock(qtty_diff = nil)
    qtty = qtty_diff.presence || quantity
    product.tree_plantations.where('tree_plantations.trees_quantity >= ?', qtty)
           &.reorder(trees_quantity: :desc)&.first
  end

  def tree_or_personalized?
    tree? || personalized?
  end

  private

  def plantation_with_largest_stock
    product.tree_plantations.where('tree_plantations.trees_quantity >= 0')
           &.reorder(trees_quantity: :desc)&.first
  end

  def url_certificate
    url_for(certificate_background)
  end

  def manage_stock_quantites_if_change_sku
    return if (product_sku_id_was == product_sku_id) || new_record?

    product_sku.decrement(:quantity, quantity_was)
  end

  def decrement_stock_quantities
    product_sku.decrement(:quantity, added_quantity)     unless tree_or_personalized?
    tree_plantation&.decrement(:quantity, added_quantity) if tree_or_personalized?
  end

  def increment_stock_quantities_destroy
    product_sku&.increment(:quantity, quantity)     unless tree_or_personalized?
    product_sku&.save                               unless tree_or_personalized?
    tree_plantation&.increment(:quantity, quantity) if tree_or_personalized?
    tree_plantation&.save                           if tree_or_personalized?
  end

  def set_cart_to_correct_delivery_type
    order.to_correct_delivery_type
  end

  def sufficient_plantation_stock
    return unless added_quantity.positive?

    persisted? ? check_stock_update : check_stock_new
  end

  def check_stock_new
    return if plantation_with_stock

    message = I18n.t('insufficient_stock')
    count = plantation_with_stock&.trees_quantity ||
            plantation_with_largest_stock&.trees_quantity || 0
    errors.add(:quantity, :insufficient_stock, message: message, count: count)
  end

  def check_stock_update
    return if plantation_with_stock(added_quantity)

    message = I18n.t('insufficient_stock')
    count = plantation_with_stock(added_quantity)&.trees_quantity ||
            plantation_with_largest_stock&.trees_quantity || 0
    errors.add(:quantity, :insufficient_stock, message: message, count: count)
  end
end
