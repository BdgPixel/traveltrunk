Rails.application.routes.draw do
  get 'deals' => 'deals#index'
  get 'deals/search' => 'deals#search'

  devise_for :users
  root 'home#index'

  resource :profile, except: [:destroy, :new, :create]
  get 'home/index'

end
