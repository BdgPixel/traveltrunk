Rails.application.routes.draw do
  resources :groups do
    collection do
      get :users_collection, as: :users_collection
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
