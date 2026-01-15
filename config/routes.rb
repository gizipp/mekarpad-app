Rails.application.routes.draw do
  # Authentication routes
  resource :session, only: [ :new, :create, :destroy ] do
    get :verify, on: :collection
    post :validate_otp, on: :collection
    post :resend_otp, on: :collection
  end

  # User profile routes
  resource :user, only: [ :edit, :update ]

  # Dashboard
  get "/dashboard", to: "dashboard#index", as: :dashboard

  # Reading lists
  resources :reading_lists, only: [:index, :create, :destroy]

  # Story routes with nested resources
  resources :stories do
    collection do
      get :my_stories
    end

    # Chapters nested under stories
    resources :chapters, only: [ :show, :new, :create, :edit, :update, :destroy ] do
      member do
        patch :publish
        patch :unpublish
      end
    end
  end

  # Root path - stories index
  root "stories#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
