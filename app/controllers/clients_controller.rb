# frozen_string_literal: true

class ClientsController < ApplicationController
  before_action :authenticate_client!

  def show
    @markers = current_client.markers
    @orders = current_client.orders.finished.order_by_date.includes \
      :delivery_address, :line_items, :invoice_attachment
    @line_items = current_client.line_items.certificated.sort_by(&:created_at).reverse

    documentation
    stats
  end

  private

  def stats
    @quantity_of_trees_planted = current_client.quantity_of_trees_planted
    @tonne_co2_captured = current_client.tonne_co2_captured
  end

  def documentation
    @docs = []
    @line_items.map(&:tree_plantation)&.compact&.map do |tp|
      if tp.producer_presentation.attached?
        @docs << { tp_id: tp.id, type: :producer_presentation,
          filename: tp.producer_presentation.blob.filename.to_s }
      end

      if tp.project_presentation.attached?
        @docs << { tp_id: tp.id, type: :project_presentation,
          filename: tp.project_presentation.blob.filename.to_s }
      end
    end
    @docs.uniq! { |doc| doc[:filename] }
  end
end
