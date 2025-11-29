Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root 'pages#home'

  get '/auth/register', to: 'users#new', as: :auth_register
  post '/auth/register', to: 'users#create'

  get '/auth/login', to: 'sessions#new', as: :auth_login
  post '/auth/login', to: 'sessions#create'
  post '/auth/logout', to: 'sessions#destroy', as: :auth_logout

  get '/dashboard', to: 'dashboards#show', as: :dashboard

  resource :profile, only: [:show, :edit, :update]

  get '/search/listings', to: 'listings#search'
  resources :listings, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    member do
      patch :verify, to: 'verification_requests#verify'
    end
  end
  resources :verification_requests, only: [:index]
  
  resources :matches, only: [:index, :show] do
    collection do
      post :generate, to: 'matches#generate'
    end
    member do
      post :like, to: 'matches#like'
    end
  end
end
