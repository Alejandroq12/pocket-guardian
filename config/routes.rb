Rails.application.routes.draw do
  devise_for :users

  # get 'users/edit/:id', to: 'users#edit', as: :edit_user

  resources :movements, only: [:new, :create]
  resources :users, only: [] do
    resources :groups, only: [:new, :show, :create, :destroy] do
      resources :movements, only: [:new, :show, :create, :destroy]
    end
  end

  # resources :groups, only: [:edit, :update, :destroy]
  # resources :movements, only: [:new, :create, :destroy]

  authenticated :user do
    root 'groups#index', as: :authenticated_root
  end

  root "splash_page#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
