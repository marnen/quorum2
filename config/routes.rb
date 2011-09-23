# coding: UTF-8

Quorum2::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # For restful_authentication:
  resources :users
  resource :user_session
  
  # And some prettification...
  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'register' => 'users#new', :as => :register
  match 'reset' => 'users#reset', :as => :reset_password
  match 'regenerate_key' => 'users#regenerate_key', :as => :regenerate_key

  match 'profile' => 'users#edit', :as => :profile


  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  root :to => 'events#index'

  match 'events/index' => 'events#index'
  
  match 'events/feed.:format/:key' => 'events#feed', :as => :feed_events
  resources :events do
    member { get :map }
  end

  resources :permissions do
    member do
      get :destroy
    end
  end
  resources :calendars
  
  match 'subscriptions' => 'permissions#index', :as => :subscriptions
  match 'subscribe/:calendar_id' => 'permissions#subscribe', :as => :subscribe
  
  # Some stuff for sorting the event list
  match 'events/index/:order/:direction' => 'events#index', :direction => /(a|de)sc/, :defaults => { :order => 'date', :direction => 'asc' }
  
  match ':controller' => '#index'

  match ':controller/:id/:action' => '#index'
  match '/:controller(/:action(/:id))'
  match ':controller/:action' => '#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # TODO: See if we can disable this route.
  match ':controller(/:action(/:id(.:format)))'
end
