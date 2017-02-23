Rails.application.routes.draw do

  devise_for :users,
    controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  get 'events/show'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '(:locale)', locale: /fr/ do
    root to: 'pages#home'
    resources :events, only: [:index, :show] do
      member do
        put "bookmark", to: "events#bookmark"
        put "remove_bookmark", to: "events#remove_bookmark"
      end
    end
    resources :users, only: [:show, :edit, :update] do
      resources :events, only: [:show]
    end
     get '/scan_playlist' => 'users#scan_playlist', as: :scan_playlist
  end
end
