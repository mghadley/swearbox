Rails.application.routes.draw do
  get 'pages/score_board'

  get 'auth/developer', as: 'developer_auth'
  get 'auth/github', as: 'github_auth'
  match "/auth/:provider/callback" => "sessions#create", :via => [:get, :post]

  get 'sessions/destroy', as: 'logout'

  root "pages#home"

end
