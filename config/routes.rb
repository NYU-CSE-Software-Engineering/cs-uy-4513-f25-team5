Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resources :listings, only: [:show]
  get '/verification_requests', to: 'verification_requests#index'
  match '/listings/:id/verify', to: 'verification_requests#verify', via: [:patch, :post], as: :verify_listing
end
