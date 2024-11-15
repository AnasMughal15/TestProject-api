Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  devise_scope :user do
    get "signup", to: "users/registrations#new", as: :signup
    post "signup", to: "users/registrations#create"
    get "login", to: "users/sessions#new", as: :login
    post "login", to: "users/sessions#create"
    delete "logout", to: "users/sessions#destroy", as: :logout
  end


  resources :projects

  get "developers", to: "projects#available_developers"
  delete "project_users/:project_id/:user_id", to: "project_users#destroy"

  resources :projects do
    resources :bugs, only: [ :index, :create, :show, :update, :destroy ]
    get "developers", to: "bugs#project_developers", on: :member
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
