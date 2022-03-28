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
      begin
        JWT.decode(token, billing_secret_key, true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def accessable_service
    if decoded_token
      initiator = decoded_token[0]['initiator']
      assign_initiator_if_it_exist(initiator)
    end
  end

  def assign_initiator_if_it_exist(initiator)
    case initiator
    when 'registry'
      @initiator = 'registry'
      true
    when 'eeid'
      @initiator = 'eeid'
      true
    when 'auction'
      @initiator = 'auction'
      true
    else
      false
    end
  end

  def logged_in?
    !!accessable_service
  end

  def authorized
    render json: { message: 'Access denied', code: '403' }, status: :unauthorized unless logged_in?
  end

  def billing_secret_key
    ENV['billing_secret']
  end

  def logger
    Rails.logger
  end
end
