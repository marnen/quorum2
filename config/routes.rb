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
  map.resources :users
  map.resource :user_session
  
  # And some prettification...
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.register 'register', :controller => 'users', :action => 'new'
  map.reset_password 'reset', :controller => 'users', :action => 'reset'
  map.regenerate_key 'regenerate_key', :controller => 'users', :action => 'regenerate_key'
  
  map.profile 'profile', :controller => 'users', :action => 'edit'

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  map.root :controller => 'events'
  
  map.connect 'events/index', :controller => 'events', :action => 'index'
  
  map.feed_events 'events/feed.:fmt/:key', :controller => 'events', :action => 'feed' # can't use :format with this URL syntax
  map.resources :events
  
  map.resources :permissions, :member => {:destroy => :get}
  map.resources :calendars
  
  map.subscriptions 'subscriptions', :controller => 'permissions', :action => 'index'
  map.subscribe 'subscribe/:calendar_id', :controller => 'permissions', :action => 'subscribe'
  
  # Some stuff for sorting the event list
  map.connect 'events/index/:order/:direction', :controller => 'events', :action => 'index', :direction => /(a|de)sc/, :defaults => {:order => 'date', :direction => 'asc'}
  
  map.connect ':controller', :action => 'index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # TODO: See if we can disable this route.
  match ':controller(/:action(/:id(.:format)))'
end
