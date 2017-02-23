Rails.application.routes.draw do
  
  get 'home/index'

  devise_for :users
  resources :loans
  resources :loan_urls
  
  root to: "home#index"
  
  #get 'home/test'=> 'home#test'
  get 'loans/:id'=>'loans#show'
  get 'loans'=>'loans#index'
  post 'loans/edit_field/:id/:field'=>'loans#edit_field'
  get 'loans/docs/:id'=>'loans#docs'
  post 'loans/:id/edit_category'=>'loans#edit_category'
  post 'loans/edit_loan_type'=>'loans#edit_loan_type'
  post 'loans/images/:id'=>'loans#images'
  get 'loans/image/:id/:image_id'=>'loans#image'
  post 'loans/:id/upload_main_image'=>'loans#upload_main_image'
  post 'loans/:id/upload_image'=>'loans#upload_image'
  post 'loans/:id/delete_image'=>'loans#delete_image'
  get 'loans/view_doc/:id'=>'loans#view_doc'
  post 'loans/upload_doc/:id'=>'loans#upload_doc'
  post 'loans/update_amount_owed/:id'=>'loans#update_amount_owed'
  post 'loans/archive/:id'=>'loans#archive'
  post 'loans/remove_reminder'=>'loans#remove_reminder'

  post 'loan_urls/:id/generate_url'=>'loan_urls#generate_url'
  post 'loan_urls/:id/extend_date'=>'loan_urls#extend_date'  
  post 'loan_urls/:id'=>'loan_urls#destroy'
  post 'loan_urls/:id/email_link'=>'loan_urls#email_link'

  #post 'loans/get_url/:id'=>'loans#get_url'
  #post 'loans/reset_url/:id'=>'loans#reset_url'
  #get 'loans/reset_url/:id'=>'loans#reset_url'
  #post 'loans/nda'=>'loans#nda_signed'

  #get 'loans/temp/get_images'=>'loans#temp'




  #admin links
  get 'admin' =>'admin#index'
  get "admin/new_user" => "admin#new_user", as: :admins_new_user
  post "admin/create_user" => "admin#create_user", as: :admins_create_user
  
  get "admin/edit_user/:id" => "admin#edit_user", as: :admins_edit_user
  patch "admin/edit_user/:id" => "admin#update_user", as: :admins_update_user
  delete "admin/destroy_user/:id" => "admin#destroy_user", as: :admins_destroy_user



  #routes for api calls to handle links in emails and campaign requests
  namespace :api do
    #resources :actions
    post '/match_lenders/:id/:token'=>'actions#match_lender'
    get '/shop_loan/:id/:token'=>'actions#shop_loan'
    get '/keep_loan/:id/:token'=>'actions#keep_loan'
    get '/indicate_interest/:id/:token'=>'actions#indicate_interest'
    get '/declined_interest/:id/:token'=>'actions#declined_interest'
    post '/manual_shop_loan/:id/:token'=>'actions#manual_shop_loan'

  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
