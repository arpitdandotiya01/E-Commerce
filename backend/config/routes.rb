Rails.application.routes.draw do
  devise_for :users
  namespace :api do
    namespace :v1 do
      get "health", to: "health#index"
    end
  end
end
