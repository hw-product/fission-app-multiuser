Rails.application.routes.draw do

  namespace :admin do
    resources :accounts do
      # resources :users
      # resources :permissions
      # resources :tokens
    end
    # resources :users do
    #   resources :tokens
    # end
    resources :sources do
      resources :accounts
    end
    # resources :permissions

    resources :products, :except => [:show]
    resources :permissions
    resources :plans

  end

  # resources :accounts do
  #   resources :tokens
  # end

  # resources :users do
  #   resources :tokens
  # end

  get 'login', :to => 'sessions#new', :as => :new_session
  get 'logout', :to => 'sessions#destroy', :as => :destroy_session

  scope :auth do
    post 'identity/authenticate', :to => 'sessions#authenticate', :as => :authenticate_user
    post ':provider/register', :to => 'users#create', :as => :register_user
    match ':provider/callback', :to => 'sessions#create', :as => :create_session, :via => [:get, :post]
    get 'failure', :to => 'sessions#failure'
  end

  get 'register', :to => 'users#new', :as => :registration

  get 'style/:name.css', :to => 'product_style#stylesheet', :as => :product_style

end
