module API
  module V1
    class BaseController < ApplicationController
      def index
        render json: { status: 'ok', time: Time.current }
      end
    end
  end
end
