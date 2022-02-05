class Api::V1::InvoiceGenerator::BaseController < ApplicationController
  include ActionController::MimeResponds
  # before_action :check_token

#  crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
# irb(main):047:0> encrypted_data = crypt.encrypt_and_sign('PLEASE CREATE INVOICE')
# => 
# irb(main):048:0> decrypted_back = crypt.decrypt_and_verify(encrypted_data)
# => 
# Rails.application.credentials.dig(:secret_key_base)

  def check_token
    token = request.headers['Authorization'].split(' ')[1] if request

    data = base_key.decrypt_and_verify(token)

    return true if data == GlobalVariable::INVOICE_SECRET_WORD

    head :forbidden
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    head :forbidden
  end

  private

  def base_key
    ActiveSupport::MessageEncryptor.new(Rails.application.credentials.dig(:secret_key_base)[0..31], Rails.application.credentials.dig(:secret_key_base))
  end
end
