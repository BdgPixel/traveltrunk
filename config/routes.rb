Rails.application.routes.draw do
  get 'savings' => 'savings#index'

  get 'notifications' => 'notifications#index'

  resource :group, only: [] do
    collection do
      get 'users_collection'
      get 'accept_invitation'
      get 'invite', as: 'invite'
    end
  end


  get 'deals' => 'deals#index'
  get 'deals/:id/show' => 'deals#show', as: 'deals/show'
  get 'deals/:id/like' => 'deals#like', as: 'deals/like'
  get 'deals/next' => 'deals/next'
  get 'deals/previous' => 'deals/previous'
  post 'deals/search' => 'deals#search'
  post 'deals/create_destination' => 'deals/create_destination'

  devise_for :users

  root 'deals#index'

  resource :profile, except: [:destroy, :new, :create]

  get 'home/index'

end
