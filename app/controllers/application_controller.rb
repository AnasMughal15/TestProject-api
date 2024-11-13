class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  protect_from_forgery with: :null_session, if: -> { request.format.json? }
  before_action :authenticate_request

  attr_reader :current_user

  private

  def authenticate_request
    # debugger
    header = request.headers["Authorization"]
    token = header.split(" ").last if header
    decoded = decode_token(token)

    if decoded
      @current_user = User.find_by(id: decoded[:user_id])
      # debugger
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def decode_token(token)
    # debugger
    decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue => e
    Rails.logger.error "JWT Decode Error: #{e.message}"
    nil
  end
end
