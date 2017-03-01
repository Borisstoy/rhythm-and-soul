Rails.application.routes.draw do
    # Sidekiq Web UI, only for admins.
  require "sidekiq/web"
  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, :skip => [:sessions], controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  as :user do
    delete "/sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
  end

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
     get '/scan_playlist' => 'artists#scan_playlist', as: :scan_playlist
     resources :artists, only: [:show]
  end
end
