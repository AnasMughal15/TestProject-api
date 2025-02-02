class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  protect_from_forgery with: :null_session, if: -> { request.format.json? }
  before_action :authenticate_request

  attr_reader :current_user

  rescue_from CanCan::AccessDenied, with: :handle_unauthorized_access
  rescue_from JWT::DecodeError, with: :handle_jwt_error

  private

  def authenticate_request
    header = request.headers["Authorization"]
    token = header.split(" ").last if header
    decoded = decode_token(token)

    if decoded
      @current_user = User.find_by(id: decoded[:user_id])
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    handle_unauthorized_access
  end

  def decode_token(token)
    decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue => e
    Rails.logger.error "JWT Decode Error: #{e.message}"
    nil
  end

  def handle_unauthorized_access
    render json: { error: "You are not authorized to perform this action" }, status: :forbidden
  end

  def handle_jwt_error
    render json: { error: "Invalid or expired token" }, status: :unauthorized
  end
end
