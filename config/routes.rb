Rails.application.routes.draw do
  get 'accounts/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resources :accounts, only: [:show] do
    resources :account_entries, only: :create
  end

  get '/clientes/:id/extrato', to: 'accounts#show', as: :transactions
  post '/clientes/:account_id/transacoes', to: 'account_entries#create', as: :add_account_entry
end
