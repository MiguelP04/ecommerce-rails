Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  namespace :api do
    namespace :v1 do
      resources :products, only: [ :index, :show, :create, :update, :destroy ]
      resources :categories, only: [ :index, :show, :create, :update, :destroy ]

      post "auth/login", to: "auth#login"
      post "auth/signup", to: "auth#signup"
      post "auth/google", to: "auth#google"
      post "auth/forgot_password", to: "auth#forgot_password"
      post "auth/reset_password", to: "auth#reset_password"
      get "auth/me", to: "auth#me"
      post "auth/logout", to: "auth#logout"
      post "auth/refresh", to: "auth#refresh"

      get "cart", to: "carts#show"
      post "cart/items", to: "carts#add_item"
      patch "cart/items/:id", to: "carts#update_item"
      delete "cart/items/:id", to: "carts#destroy_item"
      delete "cart", to: "carts#clear"

      resources :orders, only: [ :index, :show, :create ] do
        member do
          patch :cancel
        end
      end

      namespace :admin do
        resources :orders, only: [ :index, :update ]
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
