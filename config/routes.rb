Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  Rails.application.routes.draw do
    post "/webhooks/rapid7", to: "webhooks#rapid7"
  end
  
end
