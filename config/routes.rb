Rails.application.routes.draw do
  get 'deals' => 'deals#index'
  get 'deals/search' => 'deals#search'
  get 'deals/:id/show' => 'deals#show', as: 'deals/show'
  get 'deals/:id/like' => 'deals#like', as: 'deals/like'

  devise_for :users
  root 'home#index'

  resource :profile, except: [:destroy, :new, :create]
  get 'home/index'

end
