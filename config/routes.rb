Rails.application.routes.draw do
  mount ActionCable.server => "/cable"

  root "landing#index"
  resource :session
  resources :passwords, param: :token
  resources :confirmations, param: :token, only: %i[new create show]
  resource :registration, only: %i[new create]

  get "sign_in" => "sessions#new", as: :sign_in
  get "sign_up" => "registrations#new", as: :sign_up

  post "auth/:provider" => "sessions#passthru", as: :omniauth_authorize,
       constraints: { provider: /google_oauth2/ }
  get "auth/:provider/callback" => "sessions#omniauth",
      constraints: { provider: /google_oauth2/ }
  match "auth/failure" => "sessions#omniauth_failure", via: %i[get post]

  resource :onboarding, only: [ :show ], controller: "onboarding" do
    post :scan
    post :next_step
    post :back
    post :finish
    post :skip
  end

  namespace :onboarding do
    resources :competitors, only: [ :create, :destroy ]
    resources :prompts, only: [ :create, :destroy ]
  end

  get "overview" => "overview#index", as: :overview

  resources :scans, only: [ :create ]
  resources :reports, only: [ :index, :create ] do
    member { get :download }
    collection { get :download_all }
  end
  resources :prompts, only: [ :create, :update, :destroy ]
  resources :recommendations, only: [] do
    member do
      post :apply
      post :dismiss
    end
    collection do
      post :regenerate
    end
  end


  if Rails.env.development?
    get "dev/components" => "dev/components#index"
    mount MailboxGem::Engine, at: "/mailbox", as: "mailbox_gem"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
