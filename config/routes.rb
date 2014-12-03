Rails.application.routes.draw do

  namespace :admin do
    resources :accounts do
      post 'product_feature/:product_feature_id', :to => 'accounts#add_product_feature', :as => :add_product_feature
      delete 'product_feature/:product_feature_id', :to => 'accounts#remove_product_feature', :as => :remove_product_feature
      resources :users
      resources :permissions
      resources :tokens
    end
    resources :users do
      resources :tokens
    end
    resources :sources do
      resources :accounts
    end
    resources :permissions
  end

  resources :accounts do
    resources :tokens
  end

  resources :users do
    resources :tokens
  end

  get 'login', :to => 'sessions#new', :as => :new_session
  get 'logout', :to => 'sessions#destroy', :as => :destroy_session

  scope :auth do
    post 'identity/authenticate', :to => 'sessions#authenticate', :as => :authenticate_user
    post ':provider/register', :to => 'users#create', :as => :register_user
    match ':provider/callback', :to => 'sessions#create', :as => :create_session, :via => [:get, :post]
    get 'failure', :to => 'sessions#failure'
  end

  get 'register', :to => 'users#new', :as => :registration

end
