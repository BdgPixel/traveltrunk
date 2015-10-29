Rails.application.routes.draw do
  get 'savings' => 'savings#index'

  get 'notifications/index'

  resources :groups do
    collection do
      get 'users_collection'
      get 'accept_invitation'
    end

    member do
      get 'invite', as: 'invite'
    end
  end


  get 'deals' => 'deals#index'
  get 'deals/search' => 'deals#search'
  get 'deals/:id/show' => 'deals#show', as: 'deals/show'
  get 'deals/:id/like' => 'deals#like', as: 'deals/like'
  post 'deals/create_destination' => 'deals/create_destination'

  devise_for :users

  root 'deals#index'

  resource :profile, except: [:destroy, :new, :create]

  get 'home/index'

end
