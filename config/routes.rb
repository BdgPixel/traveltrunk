Rails.application.routes.draw do
  devise_for :users
  root 'home#index'

  resource :profile, except: [:destroy, :new, :create]
  get 'home/index'

end
