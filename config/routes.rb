PaypalExamples::Application.routes.draw do

  resources :products

  root to: 'products#index'

  resources :adaptives, only: [:create] do
    match 'pay', :on => :collection, :via => [:post]
    match 'preapproval_details', :on => :collection, :via => [:post]
    match 'payment_details', :on => :collection, :via => [:post]
    match 'confirm', :on => :collection, :via => [:post]
    match 'cancel', :on => :collection, :via => [:post] #put? é pa sair n temos privilegios
  end

  resources :merchants, only: [:create] do
    match 'set_checkout', :on => :collection, :via => [:post]
    match 'get_checkout', :on => :collection, :via => [:post]
    match 'do_checkout', :on => :collection, :via => [:post]
    match 'do_capture', :on => :collection, :via => [:post]
    match 'do_void', :on => :collection, :via => [:post] #put?
  end  

  match '/return',  to: 'merchants#do_checkout'
  match '/cancel',  to: 'merchants#cancel'

  mount MerchantSamples::Engine => "/samples" if Rails.env.development?

  #mount AdaptivePaymentsSamples::Engine => "/samples" if Rails.env.development?

  
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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
