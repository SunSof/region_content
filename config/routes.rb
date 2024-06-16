Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  require 'sidekiq/web'

  Rails.application.routes.draw do
    mount Sidekiq::Web => '/sidekiq'
  end

  root "pages#index"

  get "users/new" => "users#new", as: "new_user"
  post "users/new" => "users#create"

  get "users/:id" => "users#show", as: "user"

  get "login" => "user_sessions#new", as: "login"
  post "login" => "user_sessions#create"
  post "logout" => "user_sessions#destroy", as: "logout"


  get "posts/new" => "posts#new", as: "new_post"
  post "posts/new" => "posts#create"

  get "posts/:id" => "posts#show", as: "post"
  patch "posts/:id" => "posts#submit_for_review", as: "submit_for_review"

  patch "posts/:id/approve" => "posts#approve", as: "approve"
  patch "posts/:id/reject" => "posts#reject", as: "reject"

  get "/all_region" => "posts#all_region", as: "all_region_posts"
  get "/drafts" => "posts#drafts", as: "drafts"
  get "/all_user_posts" => "posts#all_user_posts", as: "all_user_posts"

  get "/all_review_posts" => "posts#all_review_posts", as: "all_review_posts"

end
