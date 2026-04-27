Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :products, only: [ :index, :show, :create, :update, :destroy ]
      resources :categories, only: [ :index, :show, :create, :update, :destroy ]

      post :login, to: "auth#login"
      post :signup, to: "auth#signup"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
