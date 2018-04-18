# frozen_string_literal: true

# == Schema Information
#
# Table name: variabilizations
#
#  id             :integer          not null, primary key
#  product_sku_id :integer
#  variant_id     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Foreign Keys
#
#  fk_rails_...  (product_sku_id => product_skus.id)
#  fk_rails_...  (variant_id => variants.id)
#

class Variabilization < ApplicationRecord
  belongs_to :product_sku
  belongs_to :variant

  delegate :category, :value, to: :variants, prefix: true
end
