class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_request, only: [ :create ]
  respond_to :json

  def create
    user = User.find_for_database_authentication(email: params[:email])
    # user = User.find_for_database_authentication(email: params[:user][:email])

    if user&.valid_password?(params[:password])
      render json: { message: "Logged in successfully", user_type: user.user_type, token: jwt_token(user) }, status: :ok
    else
      render json: { errors: [ "Invalid email or password" ] }, status: :unauthorized
    end
  end

  def destroy
    # Revoke the JWT token on logout
    current_user.update(jti: nil)
    render json: { message: "Logged out successfully" }, status: :ok
  end

  private

  def jwt_token(user)
    JWT.encode({ user_id: user.id, user_type: user.user_type, exp: 30.minutes.from_now.to_i }, Rails.application.credentials.secret_key_base)
  end
end
