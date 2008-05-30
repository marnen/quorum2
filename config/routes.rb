ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # For restful_authentication:
  map.resources :users, :collection => {:list => :any}
  map.resource :session
  
  # And some prettification...
  map.login 'login', :controller => 'sessions', :action => 'new'
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  map.register 'register', :controller => 'users', :action => 'new'
  
  map.profile 'profile', :controller => 'users', :action => 'edit'

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  map.root :controller => 'event', :action => 'list'

  # Some stuff for sorting the event list
  map.connect 'event/list/:order/:direction', :controller => 'event', :action => 'list', :direction => /(a|de)sc/, :defaults => {:order => 'date', :direction => 'asc'}

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action'
  map.connect ':controller/:id/:action'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
