Rails.application.routes.draw do
  devise_for :users, skip: :all
  namespace :api do
    namespace :v1 do
      get "health", to: "health#index"

      devise_scope :user do
        post 'login', to: 'sessions#create'
        delete 'logout', to: 'sessions#destroy'
      end

      resources :products, only: [ :index, :show, :create, :update, :destroy ]

      get "test", to: proc { [ 200, {}, ["OK"] ] } 
    end
  end
end
