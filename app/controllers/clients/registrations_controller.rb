# frozen_string_literal: true

class Clients::RegistrationsController < DeviseInvitable::RegistrationsController
  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      redirect_to new_client_session_path, notice: show_notice(resource.errors.full_messages.first(2))
      # respond_with resource
    end
  end

  def show_notice(messages)
    messages[1].include?('rempli(e)') ? messages[1].split.first(5).push('rempli').join(' ') : ''
  end

  private

  def after_update_path_for(_resource)
    clients_path
  end
end
