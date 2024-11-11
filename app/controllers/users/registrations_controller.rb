class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate_request, only: [ :create ]
  respond_to :json

  def create
    build_resource(sign_up_params)
    resource.save
    if resource.persisted?
      render json: { message: "User created successfully", user: resource, user_type: user.user_type, token: jwt_token(resource) }, status: :created
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def jwt_token(user)
    # Generate JWT token for the user
    JWT.encode({ user_id: user.id, user_type: user.user_type, exp: 30.minutes.from_now.to_i }, Rails.application.credentials.secret_key_base)
  end

  def sign_up_params
    params.permit(:email, :password, :name, :user_type)
  end

  def account_update_params
    params.permit(:email, :password, :name, :user_type)
  end
end
