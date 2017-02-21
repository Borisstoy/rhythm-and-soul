Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '(:locale)', locale: /fr/ do
    root to: 'pages#home'
    resources :events, only: [:index, :show] do
      resources :bookmarks, only: [:index, :show,:create]
    end
    resources :users, only: [:show, :edit, :update]
  end
end
