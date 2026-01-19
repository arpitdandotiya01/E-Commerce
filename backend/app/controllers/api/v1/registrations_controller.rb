module Api
  module V1
    class RegistrationsController < ApplicationController
      respond_to :json

      # POST /api/v1/signup
      def create
        user = User.new(user_params)
        # default role
        user.role = :user unless user.role

        if user.save
          token = jwt_token(user)
          render json: { message: "Signed up successfully", token: token, user: { id: user.id, email: user.email } }, status: :created
        else
          render json: { error: user.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        # Accept nested user params or flat params from frontend
        params.fetch(:user, params).permit(:email, :password, :password_confirmation)
      end

      def jwt_token(user)
        payload = { sub: user.id, scp: "user", aud: nil, iat: Time.current.to_i, exp: 24.hours.from_now.to_i, jti: SecureRandom.uuid }
        JWT.encode(payload, Rails.application.secret_key_base)
      end
    end
  end
end
