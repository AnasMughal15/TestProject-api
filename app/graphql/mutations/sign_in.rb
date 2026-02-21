# frozen_string_literal: true

module Mutations
  class SignIn < Mutations::BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    field :token, String, null: true
    field :user, Types::UserType, null: true
    field :errors, [ String ], null: false

    def resolve(email:, password:)
      user = User.find_for_database_authentication(email: email)

      if user&.valid_password?(password)
        { token: jwt_token(user), user: user, errors: [] }
      else
        { token: nil, user: nil, errors: [ "Invalid email or password" ] }
      end
    end

    private

    def jwt_token(user)
      JWT.encode(
        { user_id: user.id, user_type: user.user_type, jti: user.jti, exp: 30.minutes.from_now.to_i },
        Rails.application.credentials.secret_key_base
      )
    end
  end
end
