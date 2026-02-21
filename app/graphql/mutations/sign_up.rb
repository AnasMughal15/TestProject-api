# frozen_string_literal: true

module Mutations
  class SignUp < Mutations::BaseMutation
    argument :name, String, required: true
    argument :email, String, required: true
    argument :password, String, required: true
    argument :user_type, String, required: true

    field :token, String, null: true
    field :user, Types::UserType, null: true
    field :errors, [ String ], null: false

    def resolve(name:, email:, password:, user_type:)
      user = User.new(name: name, email: email, password: password, user_type: user_type)

      if user.save
        { token: jwt_token(user), user: user, errors: [] }
      else
        { token: nil, user: nil, errors: user.errors.full_messages }
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
