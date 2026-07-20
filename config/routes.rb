Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  root "landing#index"

  if Rails.env.development?
    get "dev/components" => "dev/components#index"
  end
end
