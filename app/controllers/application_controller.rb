class ApplicationController < ActionController::API
  before_action :authorized

  def encode_token(payload)
    JWT.encode(payload, ENV['secret_word'])
  end

  def auth_header
    # { Authorization: 'Bearer <token>' }
    request.headers['Authorization']
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      # header: { 'Authorization': 'Bearer <token>' }
      begin
        JWT.decode(token, ENV['secret_word'], true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def accessable_service
    if decoded_token
      decoded_token[0]['data'] == GlobalVariable::SECRET_WORD
    end
  end

  def logged_in?
    !!accessable_service
  end

  def authorized
    render json: { message: 'Access denied', code: '403' }, status: :unauthorized unless logged_in?
  end

  def logger
    Rails.logger
  end
end
