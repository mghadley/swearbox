Rails.application.routes.draw do
  get 'sins/index'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get 'pages/payment'
  get 'login', to: 'pages#login'
  get 'waiting_room', to: 'pages#waiting_room'
  get 'room_of_accounting', to: 'sins#index'
  get 'hall_of_shame', to: 'users#hall_of_shame'
  get 'check_crawler', to: 'users#check_crawler'
  get 'no_sins', to: 'sins#no_sins'

  get 'auth/developer', as: 'developer_auth'
  get 'auth/github', as: 'github_auth'
  match "/auth/:provider/callback" => "sessions#create", :via => [:get, :post]

  get 'sessions/destroy', as: 'logout'

  put 'recrawl', to: 'users#recrawl'

  root "pages#waiting_room"

  resources :charges
  resources :sins
  resources :users

end
