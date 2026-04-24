Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :products, only: [ :index, :show, :create, :update, :destroy ]
      resources :categories, only: [ :index, :show, :create, :update, :destroy ]

      get :cart, to: "cart#show"
      post :cart/items, to: "cart#add_item"
      patch :cart/items/:id, to: "cart#update_item"
      delete :cart/items/:id, to: "cart#remove_item"
      delete :cart, to: "cart#clear"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
