# frozen_string_literal: true

class Clients::RegistrationsController < DeviseInvitable::RegistrationsController
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
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
      # custom start
      # respond_with resource
      flash[:notice] = if Client.exists?(email: resource.email)
                         t('devise.errors.messages.user_exists')
                       else
                         resource.errors.full_messages.to_sentence
                                 .gsub('rempli(e)', 'rempli')
                       end
      redirect_to new_client_session_path
      # custom end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  private

  def after_update_path_for(_resource)
    clients_path
  end
end
