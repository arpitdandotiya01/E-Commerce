class ApplicationController < ActionController::API
  before_action :disable_session

  private

  def disable_session
    request.session_options[:skip] = true
  end
end
