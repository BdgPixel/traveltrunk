Rails.application.routes.draw do
  get 'deals/index'
  post 'deals/search' => 'deals#search'

  devise_for :users
  root 'home#index'

  resource :profile, except: [:destroy, :new, :create]
  get 'home/index'

end
