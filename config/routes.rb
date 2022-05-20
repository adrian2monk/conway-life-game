Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resource :games, only: [:index, :create, :destroy]

  # Defines the root path route ("/")
  root "games#index"
end
