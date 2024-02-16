Rails.application.routes.draw do
  get 'groups/index'
  get 'groups/show'
  get 'groups/new'
  get 'groups/create'
  get 'groups/edit'
  get 'groups/update'
  get 'groups/destroy'
  get 'movements/index'
  get 'movements/show'
  get 'movements/new'
  get 'movements/create'
  get 'movements/edit'
  get 'movements/update'
  get 'movements/destroy'
  get 'users/show'
  get 'users/new'
  get 'users/edit'
  get 'users/update'
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  authenticated :user do
    root 'home#index', as: :authenticated_root
  end

  root "splash_page#index"
end
