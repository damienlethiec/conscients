# frozen_string_literal: true

class ProducerPresentations::DownloadsController < ApplicationController
  def new
    @tree_plantation = TreePlantation.find(params[:tree_plantation_id])
    send_data \
      @tree_plantation.producer_presentation.download,
      disposition: 'attachment',
      filename: @tree_plantation.producer_presentation.blob.filename.to_s
  end
end
