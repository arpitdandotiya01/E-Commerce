module Api
  module V1
    class BaseController < ApplicationController
      include Pundit::Authorization

      rescue_from Pundit::NotAuthorizedError do
        render json: { error: "You are not authorized to perform this action." }, status: :forbidden
      end
    end
  end
end
