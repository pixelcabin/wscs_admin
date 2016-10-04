  namespace :admin do
    get '/' => 'base#index', as: :root
    resources :users
    resource :session, only: %i(new create destroy)
  end

