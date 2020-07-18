# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate_client!

  def edit; end
end
