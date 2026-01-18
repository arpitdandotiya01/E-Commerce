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
        # Generate JWT with payload compatible with Devise JWT verification.
        # Devise expects { sub, scp, aud, iat, exp, jti } and verifies with secret_key_base.
        payload = { sub: user.id, scp: 'user', aud: nil, iat: Time.current.to_i, exp: 24.hours.from_now.to_i, jti: SecureRandom.uuid }
        JWT.encode(payload, Rails.application.secret_key_base)
      end
    end
  end
end
