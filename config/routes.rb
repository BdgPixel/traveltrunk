Rails.application.routes.draw do
  devise_for :users
  root 'home#index'

  resource :profile, except: :destroy
  get 'home/index'

end
