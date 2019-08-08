class AddSessionTokenToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :session_token, :string, default: SecureRandom.hex
  end
end
