Rails.application.routes.draw do
  resources :posts do
    collection do
      post :import
    end
  end
end
