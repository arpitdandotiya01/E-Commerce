module Api
  module V1
    class HealthController < BaseController
      def index
        render json: { status: "ok", time: Time.current }
      end
    end
  end
end
