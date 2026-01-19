Rails.application.routes.draw do
  devise_for :users, skip: :all
  namespace :api do
    namespace :v1 do
      get "health", to: "health#index"

      devise_scope :user do
        post "login", to: "sessions#create"
        delete "logout", to: "sessions#destroy"
      end

      # Allow frontend signup route
      post "signup", to: "registrations#create"

      resources :products, only: [ :index, :show, :create, :update, :destroy ]

      resources :orders, only: [ :create, :index, :show ] do
        member do
          post :add_item
          patch :update_item
          delete :remove_item
          post :checkout
        end
      end

      resources :orders do
        member do
          patch :checkout
        end
      end


      get "test", to: proc { [ 200, {}, [ "OK" ] ] }
    end
  end
end
