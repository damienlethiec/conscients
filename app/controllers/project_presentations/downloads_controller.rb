# frozen_string_literal: true

class ProjectPresentations::DownloadsController < ApplicationController
  def new
    @tree_plantation = TreePlantation.find(params[:tree_plantation_id])
    send_data \
      @tree_plantation.project_presentation.download,
      disposition: 'attachment',
      filename: @tree_plantation.project_presentation.blob.filename.to_s
  end
end
