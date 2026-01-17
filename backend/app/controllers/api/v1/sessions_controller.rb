module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      def create
        self.resource = warden.authenticate!(auth_options)
        sign_in(resource_name, resource)

        token = jwt_token(resource)

        render json: {
          message: "Logged in successfully.",
          token: token,
          user: { id: resource.id, email: resource.email }
        }
      end

      private

      def jwt_token(user)
        JWT.encode(
          { user_id: user.id, exp: 24.hours.from_now.to_i },
          Rails.application.secret_key_base
        )
      end
    end
  end
end
