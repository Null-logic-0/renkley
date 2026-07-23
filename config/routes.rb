Rails.application.routes.draw do
  root "landing#index"
  resource :session
  resources :passwords, param: :token
  resources :confirmations, param: :token, only: %i[new create show]
  resource :registration, only: %i[new create]

  get "sign_in" => "sessions#new", as: :sign_in
  get "sign_up" => "registrations#new", as: :sign_up


  if Rails.env.development?
    get "dev/components" => "dev/components#index"
    mount MailboxGem::Engine, at: "/mailbox", as: "mailbox_gem"
  end

  get "up" => "rails/health#show", as: :rails_health_check

  post "auth/:provider" => "sessions#passthru", as: :omniauth_authorize,
       constraints: { provider: /google_oauth2/ }
  get "auth/:provider/callback" => "sessions#omniauth",
      constraints: { provider: /google_oauth2/ }
  match "auth/failure" => "sessions#omniauth_failure", via: %i[get post]

  get "overview" => "overview#index", as: :overview
end
