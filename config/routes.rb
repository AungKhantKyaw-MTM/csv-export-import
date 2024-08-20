require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  
  resources :posts do
    collection do
      post :import
    end
  end
end
