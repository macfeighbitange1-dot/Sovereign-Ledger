Rails.application.routes.draw do
  # This makes http://localhost:5000/ load your dashboard
  root "home#index"

  # This tells the "RUN" button to send data to the 'create' action in your controller
  post "messages", to: "home#create"

  # Standard Rails health check
  get "up" => "rails/health#show", as: :rails_health_check
end
