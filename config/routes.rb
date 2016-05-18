Rails.application.routes.draw do
  require 'sidekiq/web'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get 'static_pages/about_us'

  get 'static_pages/our_mission'

  get 'static_pages/privacy_policy'

  get 'static_pages/refund'

  get 'static_pages/contact_us'

  get 'static_pages/trust_and_security'

  get 'static_pages/partnerships'

  get 'static_pages/our_team'

  get 'home/index'

  get  'privacy_policy' => 'policies#privacy'
  get  'refund_policy' => 'policies#refund'
  post 'refund_policy' => 'policies#create_contact'
  
  get  'refunds/create'

  get  'promo_codes/activation'
  post 'promo_codes/update'

  namespace :admin, path: 'admin' do
    resources :reservations, only: [:index, :update]
    resources :transactions, only: [:index]
    resources :refunds, only: [:index, :update]
    resources :promo_codes
    resources :users, only: [:index, :show]
  end

  get  'helps' => 'helps#index'
  post 'helps/send_question' => 'helps#send_question'

  post '/rate' => 'rater#create', :as => 'rate'
  get 'destinations/clear'

  get  'payments' => 'payments#index'
  post 'payments/create'
  get  'payments/thank_you_page'
  post 'payments/authorize_net_webhook'
  get '/payments/authorize_net_webhook' => 'payments#get_authorize_net_webhook'

  get  'savings' => 'savings#index'

  get 'notifications' => 'notifications#index'

  resource :group, only: [] do
    collection do
      get    'users_collection'
      get    'accept_invitation'
      get    'invite', as: 'invite'
      delete 'leave_group', as: 'leave'
    end
  end

  get   'deals' => 'deals#index'
  get   'deals/:id/show' => 'deals#show', as: 'deals/show'
  get   'deals/:id/like' => 'deals#like', as: 'deals/like'
  get   'deals/next' => 'deals/next'
  get   'deals/previous' => 'deals/previous'
  get   'deals/:id/room_availability' => 'deals#room_availability', as: 'deals/room_availability'
  get   'deals/:id/room_images' => 'deals#room_images', as: 'deals/room_images'
  get   'deals/book' => 'deals#book', as: 'deals/book'
  get   'deals/confirmation_page'
  post  'deals/create_book' => 'deals#create_book', as: 'deals/create_book'
  post  'deals/search' => 'deals#search'
  post  'deals/create_destination' => 'deals/create_destination'
  # patch 'deals/update_credit' => 'deals/update_credit'
  post   'deals/update_credit' => 'deals/update_credit'

  devise_for :users, :controllers => {
    :registrations => 'registrations',
    :invitations => 'users/invitations'
  }

  # root 'deals#index'
  root 'home#index'

  resource :profile, except: [:destroy, :new, :create]
  get 'users/:id/profile' => 'profiles#show', as: 'user_profile'

  post   'create_bank_account' => 'profiles#create_bank_account'
  put    'update_bank_account' => 'profiles#update_bank_account'
  delete 'unsubscript' => 'profiles#unsubscript', as: 'unsubscript'
end
