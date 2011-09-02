Quorum2::Application.routes.draw do
  resources :users
  resource :user_session
  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'register' => 'users#new', :as => :register
  match 'reset' => 'users#reset', :as => :reset_password
  match 'regenerate_key' => 'users#regenerate_key', :as => :regenerate_key
  match 'profile' => 'users#edit', :as => :profile
  match '/' => 'events#index'
  match 'events/index' => 'events#index'
  match 'events/feed.:fmt/:key' => 'events#feed', :as => :feed_events
  resources :events
  resources :permissions do
  
    member do
  get :destroy
  end
  
  end

  resources :calendars
  match 'subscriptions' => 'permissions#index', :as => :subscriptions
  match 'subscribe/:calendar_id' => 'permissions#subscribe', :as => :subscribe
  match 'events/index/:order/:direction' => 'events#index', :direction => /(a|de)sc/, :defaults => { :order => 'date', :direction => 'asc' }
  match ':controller' => '#index'
  match ':controller/:id/:action' => '#index'
  match '/:controller(/:action(/:id))'
  match ':controller/:action' => '#index'
end