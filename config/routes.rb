Rails.application.routes.draw do
  get 'users/index'

  get 'sins/index'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get 'pages/score_board'
  get 'pages/payment'
  get 'login', to: 'pages#login'
  get 'waiting_room', to: 'pages#waiting_room'
  get 'room_of_accounting', to: 'sins#index'
  get 'hall_of_shame', to: 'users#hall_of_shame'

  get 'auth/developer', as: 'developer_auth'
  get 'auth/github', as: 'github_auth'
  match "/auth/:provider/callback" => "sessions#create", :via => [:get, :post]

  get 'sessions/destroy', as: 'logout'

  root "pages#home"

  resources :charges
  resources :sins

end
