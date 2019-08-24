# frozen_string_literal: true

class ProfilePasswordsController < ProfilesController
  before_action :authenticate_client!

  def update
    if update_with_password password_params
      redirect_to clients_path, notice: 'mise à jour effectuée'
    else
      redirect_to clients_path, notice: 'mise à jour non effectuée'
    end
  end

  private

  def update_with_password(params)
    current_password = params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = if params[:password].blank?
               false
             elsif current_client.valid_password?(current_password)
               result = current_client.update(password: params[:password])
               current_client.invalidate_all_sessions!
               bypass_sign_in(current_client.reload, scope: :client)
               result
             else
               current_client.assign_attributes(password: params[:password])
               bypass_sign_in(current_client.reload, scope: :client)

               current_client.valid?
               current_client.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
               false
    end

    params.delete(:password)
    result
  end

  def password_params
    params.require(:client).permit(:current_password, :password)
  end
end
