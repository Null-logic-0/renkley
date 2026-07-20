Rails.application.routes.draw do
  root "landing#index"
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[new create]

  get "sign_in" => "sessions#new", as: :sign_in
  get "sign_up" => "registrations#new", as: :sign_up



  if Rails.env.development?
    get "dev/components" => "dev/components#index"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
