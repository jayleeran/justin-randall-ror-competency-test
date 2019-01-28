Rails.application.routes.draw do
  resources :articles
  devise_for :users
  resources :users do
    collection do
      get :admin_new
      post :admin_create
    end
    member do
      get :admin_edit
      patch :admin_update
    end
  end
  root to: "home#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
