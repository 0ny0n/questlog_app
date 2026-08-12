Rails.application.routes.draw do
  root "pages#home"
  get "/home", to: "pages#home"
  get "/categories", to: "pages#categories"
  resources :quests do
    member do
      patch :complete
    end

    collection do
      get :archive
    end
  end

  post "/switch_user", to: "pages#switch_user"

  resources :users, only: [ :show ] do
    collection do
      get :search
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
