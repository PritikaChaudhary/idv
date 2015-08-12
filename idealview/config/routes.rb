Rails.application.routes.draw do
  
  get 'home/index'

  devise_for :users
  resources :loans
  resources :loan_urls
  
  root to: "home#index"
  
  #get 'home/test'=> 'home#test'
  get 'loans/:id'=>'loans#show'
  get 'loans/docs/:id'=>'loans#docs'
  get 'loans/show_pdf/:id'=>'loans#show_pdf'
  get 'loans'=>'loans#index'
  post 'loans/edit_field/:id/:field'=>'loans#edit_field'
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
  post 'loans/recent/:sort'=>'loans#recent'
  post 'loans/priority/:sort'=>'loans#priority'
  post 'loans/changeorder'=>'loans#changeorder'
  post 'loans/generate_pdf'=>'loans#generate_pdf'
  post 'loans/delete_loans'=>'loans#delete_loans'
  post 'loans/hide_file'=>'loans#hide_file'
  post 'loans/show_file'=>'loans#show_file'
  post 'loans/del_file'=>'loans#del_file'
  post 'loans/send_to_cpc/:id'=>'loans#send_to_cpc'
  get 'loans/application/:id' => 'loans#application'
  post "loans/create_application" => "loans#create_application"
  post 'loans/save_loc'=>'loans#save_loc'
  post 'loans/edit_info'=>'loans#edit_info'
  post 'loans/pdf'=>'loans#pdf'
  get 'loans/edit_pdf/:id' => 'loans#edit_pdf'
  post 'loans/generate_html'=>'loans#generate_html'
  post 'loans/generate_send'=>'loans#generate_send'
  post 'loans/loan_listing/:id'=>'loans#loan_listing'
  post 'loans/pdforder'=>'loans#pdforder'
  get 'loans/pdf_files/:id' => 'loans#pdf_files'
  post 'loans/custom_search'=>'loans#custom_search'
  post 'loans/post_new_loan'=>'loans#post_new_loan'
  post 'loans/incomplete_loans'=>'loans#incomplete_loans'
  post 'loans/add_folder'=>'loans#add_folder'
  post 'loans/upload_file/:id'=>'loans#upload_file'
  get 'loans/view_file/:id'=>'loans#view_file'
  post 'loans/hide_doc'=>'loans#hide_doc'
  post 'loans/show_doc'=>'loans#show_doc'
  post 'loans/del_doc'=>'loans#del_doc'
  post 'loans/del_folder'=>'loans#del_folder'
  get 'loans/detail/:id'=>'loans#detail'

  #post 'loans/application' => 'loans#application', as: :loans_application

  #get 'loans/generate_pdf'=>'loans#generate_pdf'


  post 'loan_urls/:id'=>'loan_urls#destroy'
  post 'loan_urls/:id/email_link'=>'loan_urls#email_link'
  post 'loan_urls/:id/generate_url'=>'loan_urls#generate_url'
  post 'loan_urls/:id/extend_date'=>'loan_urls#extend_date'
  post 'loan_urls/:id/save_status'=>'loan_urls#save_status'
  post 'loan_urls/:id/fetch_lenders'=>'loan_urls#fetch_lenders'
  

  get  'brokers'=>'brokers#index'
  post 'brokers/delete_brokers'=>'brokers#delete_brokers'
  post 'brokers/search'=>'brokers#search'
  get  'brokers/show/:id'=>'brokers#show'
  get  'brokers/add'=>'brokers#add'
  get  'brokers/settings'=>'brokers#settings'
  post 'brokers/update'=>'brokers#update'
  get  'brokers/allow_access/:broker_id/:sub_broker_id'=>'brokers#allow_access'
  get  'brokers/add_user'=>'brokers#add_user'
  post 'brokers/check_email'=>'brokers#check_email'
  post 'brokers/add_broker'=>'brokers#add_broker'
  get  'brokers/sub_brokers'=>'brokers#sub_brokers'
  get  'brokers/loans/:id'=>'brokers#loans'
  post 'brokers/recent/:id'=>'brokers#recent'
  post 'brokers/priority/:id'=>'brokers#priority'
  post 'brokers/custom_search'=>'brokers#custom_search'
  get  'brokers/edit_user/:id'=>'brokers#edit_user'
  post 'brokers/edit_broker'=>'brokers#edit_broker'
  get 'brokers/change_password/:id'=>'brokers#change_password'
  post 'brokers/edit_password'=>'brokers#edit_password'

  get  'lenders'=>'lenders#index'
  post 'lenders/delete_lenders'=>'lenders#delete_lenders'
  post 'lenders/:id/fetch_detail'=>'lenders#fetch_detail'
  post 'lenders/custom_search'=>'lenders#custom_search'
  post 'lenders/search'=>'lenders#search'
  post 'lenders/add_lender'=>'lenders#add_lender'
  get  'lenders/add'=>'lenders#add'
  post 'lenders/check_email'=>'lenders#check_email'

  get 'emails' => 'emails#index'
  post 'emails/update_email'=>'emails#update_email'
  #post 'loans/get_url/:id'=>'loans#get_url'
  #post 'loans/reset_url/:id'=>'loans#reset_url'
  #get 'loans/reset_url/:id'=>'loans#reset_url'
  #post 'loans/nda'=>'loans#nda_signed'

  #get 'loans/temp/get_images'=>'loans#temp'

  get "payments/select_plan" => "payments#select_plan"
  post "payments/payment_successfull" => "payments#payment_successfull"



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
