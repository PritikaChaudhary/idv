Rails.application.routes.draw do
require "resque/server"
 # mount Resque::Server.new, :at => "/resque"
 mount Resque::Server, :at => "/resque"
  get 'home/index'


  devise_for :users
  resources :loans
  resources :loan_urls


  namespace :api, :defaults => {:format => 'json'} do
    devise_for :users
    namespace :v1 do
      resources :products
    end
  end
  
  root to: "home#index"
  post 'home/login'=>'home#login'
  get 'home/sign_up/:plan'=>'home#sign_up'
  post 'home/create_broker'=>'home#create_broker'
  post 'home/checkemail'=>'home#checkemail'
  post 'home/login_page'=>'home#login_page'
  get 'home/funding_login'=>'home#funding_login'
  get 'home/logout'=>'home#logout'
  post 'home/checkuname'=>'home#checkuname'
  get 'home/cpc_login'=>'home#cpc_login'
  post 'home/save_val'=>'home#save_val'
  post 'home/idv_login'=>'home#idv_login'
  get 'home/cpc_login_page'=>'home#cpc_login_page'
  get 'home/cpc_login'=>'home#cpc_login'
  
  #get 'home/test'=> 'home#test'
  get 'loans/:id'=>'loans#show'
  get 'loans/edit_loan/:id'=>'loans#edit_loan'
  get 'loans/docs/:id'=>'loans#docs'
  get 'loans/show_pdf/:id'=>'loans#show_pdf'
  get 'loans/incomplete_fd_loans/:id'=>'loans#incomplete_fd_loans'
  get 'loans'=>'loans#index'
  post 'loans/edit_field/:id/:field'=>'loans#edit_field'
  post 'loans/side_edit_fields/:id/:field'=>'loans#side_edit_fields'
  post 'loans/borrower_edit_field/:id/:field'=>'loans#borrower_edit_field'
  post 'loans/borrowers_edit_field/:id/:field'=>'loans#borrowers_edit_field'
  post 'loans/collateral_edit_field/:id/:field'=>'loans#collateral_edit_field'
  post 'loans/collaterals_edit_field/:id/:field'=>'loans#collaterals_edit_field'
  post 'loans/:id/edit_category'=>'loans#edit_category'
  post 'loans/edit_loan_type'=>'loans#edit_loan_type'
  post 'loans/images/:id'=>'loans#images'
  get 'loans/image/:id/:image_id'=>'loans#image'
  post 'loans/:id/upload_main_image'=>'loans#upload_main_image'
  post 'loans/upload_main_imagex/:id'=>'loans#upload_main_imagex'
  post 'loans/:id/upload_image'=>'loans#upload_image'
  post 'loans/:id/delete_image'=>'loans#delete_image'
  get 'loans/view_doc/:id'=>'loans#view_doc'
  post 'loans/upload_doc/:id'=>'loans#upload_doc'
  post 'loans/update_amount_owed/:id'=>'loans#update_amount_owed'
 # post 'loans/archive/:id'=>'loans#archive'
  post 'loans/recent/:sort'=>'loans#recent'
  post 'loans/priority/:sort'=>'loans#priority'
  post 'loans/incomplete_loan/:sort'=>'loans#incomplete_loan'
  post 'loans/changeorder'=>'loans#changeorder'
  post 'loans/generate_pdf'=>'loans#generate_pdf'
  post 'loans/delete_loans'=>'loans#delete_loans'
  post 'loans/hide_file'=>'loans#hide_file'
  post 'loans/show_file'=>'loans#show_file'
  post 'loans/del_file'=>'loans#del_file'
  post 'loans/send_to_cpc'=>'loans#send_to_cpc'
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
  post 'loans/manual_shop_loan'=>'loans#manual_shop_loan'
  post 'loans/archive'=>'loans#archive'
  get  'loans/shop_loans/:id'=>'loans#shop_loans'
  get  'loans/shop_loan/:id'=>'loans#shop_loan'
  post 'loans/edit_fields/:id/:field'=>'loans#edit_fields'
  post 'loans/:id/edit_categorys'=>'loans#edit_categorys'
  get  'loans/terms/:id'=>'loans#terms'
  post 'loans/save_conditions' => 'loans#save_conditions'
  post 'loans/delete_copy_loans'=>'loans#delete_copy_loans'
  post 'loans/reject'=>'loans#reject'
  post 'loans/commit_to_shop'=>'loans#commit_to_shop'
  post 'loans/filter_shop'=>'loans#filter_shop'
  post 'loans/add_more_lender'=>'loans#add_more_lender'
  post 'loans/remove_lender'=>'loans#remove_lender'
  post 'loans/lender_order'=>'loans#lender_order'
  post 'loans/save_shop_lender'=>'loans#save_shop_lender'
  post 'loans/single_shop_loan'=>'loans#single_shop_loan'
  post 'loans/add_notes'=>'loans#add_notes'
  post 'loans/add_lender_note'=>'loans#add_lender_note'
  post 'loans/remove_by_loc'=>'loans#remove_by_loc'
  post 'loans/add_lenders'=>'loans#add_lenders'
  post 'loans/remove_reminder'=>'loans#remove_reminder'
  post 'loans/add_reminder'=>'loans#add_reminder'
  post 'loans/add_funds'=>'loans#add_funds'
  post 'loans/add_loan_funds'=>'loans#add_loan_funds'
  post 'loans/add_payoff'=>'loans#add_payoff'
  post 'loans/all_funds'=>'loans#all_funds'
  post 'loans/all_shop_funds'=>'loans#all_shop_funds'
  post 'loans/search'=>'loans#search'
  post 'loans/delete_pdf'=>'loans#delete_pdf'
  get 'loans/detail_loan/:id/:login'=>'loans#detail_loan'
  post 'loans/edit_picture'=>'loans#edit_picture'
  post 'loans/save_edit_pic'=>'loans#save_edit_pic'
  post 'loans/add_new_borrower'=>'loans#add_new_borrower'
  post 'loans/add_copy_borrower'=>'loans#add_copy_borrower'
  post 'loans/add_new_collateral'=>'loans#add_new_collateral'
  post 'loans/add_copy_collateral'=>'loans#add_copy_collateral'
  post 'loans/loan_images'=>'loans#loan_images'
  post 'loans/custom_search_pdf'=>'loans#custom_search_pdf'
  post 'loans/delete_pdfs'=>'loans#delete_pdfs'
  get 'loans/email_shop_loan/:id'=>'loans#email_shop_loan'
  post 'loans/add_copy_payoff'=>'loans#add_copy_payoff'
  post 'loans/free_clear'=>'loans#free_clear'
  post 'loans/loan_funds'=>'loans#loan_funds'
  post 'loans/add_funds_relation'=>'loans#add_funds_relation'
  post 'loans/copy_free_clear'=>'loans#copy_free_clear'
  post 'loans/copy_add_loan_funds'=>'loans#copy_add_loan_funds'
  post 'loans/copy_loan_funds'=>'loans#copy_loan_funds'
  post 'loans/add_copyfunds_relation'=>'loans#add_copyfunds_relation'
  post 'loans/add_to_priority'=>'loans#add_to_priority'
  post 'loans/remove_priority'=>'loans#remove_priority'
  get 'loans/check_mail/:id'=>'loans#check_mail'
  post 'loans/send_to_ids/'=>'loans#send_to_ids'
  post 'loans/add_related_fund'=>'loans#add_related_fund'
  post 'loans/add_fund_related'=>'loans#add_fund_related'
  post 'loans/after_related_funds'=>'loans#after_related_funds'
  post 'loans/remove_related_funds'=>'loans#remove_related_funds'
  post 'loans/edit_all_funds'=>'loans#edit_all_funds'
  post 'loans/hide_borrower'=>'loans#hide_borrower'
  post 'loans/show_borrower'=>'loans#show_borrower'
  post 'loans/hide_collateral'=>'loans#hide_collateral'
  post 'loans/show_collateral'=>'loans#show_collateral'
  post 'loans/hide_borrower_field'=>'loans#hide_borrower_field'
  post 'loans/show_borrower_field'=>'loans#show_borrower_field'
  post 'loans/hide_collateral_field'=>'loans#hide_collateral_field'
  post 'loans/show_collateral_field'=>'loans#show_collateral_field'
  post 'loans/hide_loan_field'=>'loans#hide_loan_field'
  post 'loans/show_loan_field'=>'loans#show_loan_field'
  post 'loans/is_broker'=>'loans#is_broker'
  post 'loans/new_loan'=>'loans#new_loan'
   post 'loans/save_personal_address'=>'loans#save_personal_address'
  post 'loans/save_business_address'=>'loans#save_business_address'
  post 'loans/save_guarantor_address'=>'loans#save_guarantor_address'
  post 'loans/save_collateral_address'=>'loans#save_collateral_address'
  post 'loans/save_loan_data'=>'loans#save_loan_data'
  post 'loans/fetch_loan_data'=>'loans#fetch_loan_data'
  post 'loans/hide_copyloan_field'=>'loans#hide_copyloan_field'
  post 'loans/show_copyloan_field'=>'loans#show_copyloan_field'
  post 'loans/hide_copyborrower_field'=>'loans#hide_copyborrower_field'
  post 'loans/show_copyborrower_field'=>'loans#show_copyborrower_field'
  post 'loans/hide_copycollateral_field'=>'loans#hide_copycollateral_field'
  post 'loans/show_copycollateral_field'=>'loans#show_copycollateral_field'
  post 'loans/save_copyloan_data'=>'loans#save_copyloan_data'
  post 'loans/fetch_copyloan_data'=>'loans#fetch_copyloan_data'
   get 'loans/edit_application/:id' => 'loans#edit_application'
  post 'loans/edit_loan_images'=>'loans#edit_loan_images'
  post 'loans/:id/upload_edit_image'=>'loans#upload_edit_image'
  post 'loans/:id/edit_delete_image'=>'loans#edit_delete_image'
  post "loans/edit_create_application" => "loans#edit_create_application"
  post "loans/edit_add_folder" => "loans#edit_add_folder"
  post "loans/send_email" => "loans#send_email"
  post "loans/edit_save_loan_data" => "loans#edit_save_loan_data"
  post "loans/fetch_location_map" => "loans#fetch_location_map"
  post "loans/edit_analysis_data" => "loans#edit_analysis_data"
  post "loans/update_fields" => "loans#update_fields" 
  post "loans/update_dummy_fields" => "loans#update_dummy_fields"
  post "loans/collateral_changeorder" => "loans#collateral_changeorder"
  get 'loans/admin_loan_detail' => 'loans#admin_loan_detail'
  get 'loans/admin_loan_detail/:id' => 'loans#admin_loan_detail'
  post "loans/sort_shop_loan" => "loans#sort_shop_loan"
  post "loans/save_loan_field" => "loans#save_loan_field"
  post "loans/save_collateral_field" => "loans#save_collateral_field"
  post "loans/save_borrower_field" => "loans#save_borrower_field"
  post "loans/add_copyloan_funds" => "loans#add_copyloan_funds"
  post "loans/copy_update_fields" => "loans#copy_update_fields"
  post "loans/save_copypersonal_address" => "loans#save_copypersonal_address"
  post "loans/save_copybusiness_address" => "loans#save_copybusiness_address"
  post "loans/save_copyguarantor_address" => "loans#save_copyguarantor_address"
  post "loans/save_copyborrower_field" => "loans#save_copyborrower_field"
  post "loans/save_copycollateral_address" => "loans#save_copycollateral_address"
  post "loans/save_copycollateral_field" => "loans#save_copycollateral_field"
  post "loans/edit_copyanalysis_data" => "loans#edit_copyanalysis_data"
  post "loans/save_copyloan_field" => "loans#save_copyloan_field"
  post "loans/copy_save_loan_data" => "loans#copy_save_loan_data"
  post "loans/fetch_lenders" => "loans#fetch_lenders"
  post "loans/delete_broker_loans" => "loans#delete_broker_loans"
  post "loans/save_loan_money" => "loans#save_loan_money"
  post "loans/save_borrower_money" => "loans#save_borrower_money"
  post "loans/save_collateral_money" => "loans#save_collateral_money"
  post "loans/loan_documents" => "loans#loan_documents"
  post "loans/send_form_link" => "loans#send_form_link"
  post "loans/add_new_edit_borrower" => "loans#add_new_edit_borrower"
  post "loans/add_new_edit_collateral" => "loans#add_new_edit_collateral"
  post 'loans/save_edit_loc'=>'loans#save_edit_loc'
  post "loans/add_collateral_funds" => "loans#add_collateral_funds"
  post "loans/all_loan_funds" => "loans#all_loan_funds"
  post "loans/view_loc_map" => "loans#view_loc_map"
  post "loans/estimated_market_value" => "loans#estimated_market_value"
  post "loans/add_new_loan" => "loans#add_new_loan"
  post "loans/show_overview" => "loans#show_overview"
  post "loans/new_file_upload" => "loans#new_file_upload"
  post "loans/new_loan_images" => "loans#new_loan_images"
  post "loans/new_loan_documents" => "loans#new_loan_documents"
  get "loans/embed_application/:id" => "loans#embed_application"
   post "loans/embed_loan_images" => "loans#embed_loan_images"
  post "loans/embed_file_upload" => "loans#embed_file_upload"
  post "loans/embed_loan_documents" => "loans#embed_loan_documents"
  post "loans/embed_add_new_loan" => "loans#embed_add_new_loan"
  post "loans/new_save_loan_field" => "loans#new_save_loan_field"
  post "loans/cpc_loan" => "loans#cpc_loan"
  post "loans/ids_login" => "loans#ids_login"
  post 'loans/loan_folders/:id'=>'loans#loan_folders'
  post 'loans/loan_files/:id'=>'loans#loan_files'
  post 'loans/fetch_property_info'=>'loans#fetch_property_info'
  #post 'loans/application' => 'loans#application', as: :loans_application

  #get 'loans/generate_pdf'=>'loans#generate_pdf'
  get 'subscribe/:plan'=>'subscribe#sign_up'
  post 'subscribe/create_broker'=>'subscribe#create_broker'
  post 'subscribe/checkemail'=>'subscribe#checkemail'
  get 'subscribers'=>'subscribe#index'

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
  get  'settings'=>'brokers#settings'
  post 'brokers/update'=>'brokers#update'
  get  'brokers/allow_access/:broker_id/:sub_broker_id'=>'brokers#allow_access'
  get  'brokers/add_user'=>'brokers#add_user'
  post 'brokers/check_email'=>'brokers#check_email'
  post 'brokers/add_brokers'=>'brokers#add_brokers'
  get  'brokers/sub_brokers'=>'brokers#sub_brokers'
  get  'brokers/loans/:id'=>'brokers#loans'
  post 'brokers/recent/:id'=>'brokers#recent'
  post 'brokers/priority/:id'=>'brokers#priority'
  post 'brokers/custom_search'=>'brokers#custom_search'
  get  'brokers/edit_user/:id'=>'brokers#edit_user'
  post 'brokers/edit_broker'=>'brokers#edit_broker'
  get 'brokers/change_password/:id'=>'brokers#change_password'
  post 'brokers/edit_password'=>'brokers#edit_password'
  post 'brokers/add_new_broker'=>'brokers#add_new_broker'
  post 'brokers/config_account'=>'brokers#config_account'
  post 'brokers/checkids'=>'brokers#checkids'

  get  'lenders'=>'lenders#index'
  post 'lenders/delete_lenders'=>'lenders#delete_lenders'
  post 'lenders/:id/fetch_detail'=>'lenders#fetch_detail'
  post 'lenders/custom_search'=>'lenders#custom_search'
  post 'lenders/search'=>'lenders#search'
  post 'lenders/add_lender'=>'lenders#add_lender'
  get  'lenders/add'=>'lenders#add'
  post 'lenders/check_email'=>'lenders#check_email'
   get  'lenders/potential_deals'=>'lenders#potential_deals'
  get  'lenders/loan_detail/:id'=>'lenders#loan_detail'
  post 'lenders/acept_loan'=>'lenders#acept_loan'
  post 'lenders/decline_loan'=>'lenders#decline_loan'
  post 'lenders/add_edit_lender'=>'lenders#add_edit_lender'
  get  'lenders/prefrences'=>'lenders#prefrences'
  get  'lenders/lender_agreements'=>'lenders#lender_agreements'
  get  'lenders/add_agreement'=>'lenders#add_agreement'
  post 'lenders/agreement_add'=>'lenders#agreement_add'
  post 'lenders/accept_agreement'=>'lenders#accept_agreement'
  get  'lenders/lender_cron'=>'lenders#lender_cron'
  get  'lenders/decline_cron'=>'lenders#decline_cron'
  get  'lenders/reminders'=>'lenders#reminders'
  get  'lenders/test_time'=>'lenders#test_time'
  post  'lenders/cancel_shop_loan'=>'lenders#cancel_shop_loan'
   get  'lenders/dummy_loan_detail'=>'lenders#dummy_loan_detail'
  get "lenders/groups" => "lenders#groups"
  post "lenders/add_group" => "lenders#add_group"
  get  'lenders/view_group/:id'=>'lenders#view_group'
  get  'lenders/loan/:id'=>'lenders#loan'
  post 'lenders/acept_shop_loan'=>'lenders#acept_shop_loan'
  post 'lenders/decline_shop_loan'=>'lenders#decline_shop_loan'

  get 'emails' => 'emails#index'
  post 'emails/update_email'=>'emails#update_email'
  get 'emails/edit_email/:id'=>'emails#edit_email'
  post 'emails/system_emails'=>'emails#system_emails'
  get 'emails/received_emails'=>'emails#received_emails'
  post 'emails/loan_detail'=>'emails#loan_detail'
  post 'emails/create_application'=>'emails#create_application'
  post 'emails/add_loan'=>'emails#add_loan'
  post 'emails/all_categories'=>'emails#all_categories'
  post 'emails/custom_folder'=>'emails#custom_folder'
  get 'emails/show_file/:id/:num'=>'emails#show_file'
  post 'emails/delete_file'=>'emails#delete_file'
  post 'emails/delete_emails'=>'emails#delete_emails'
  post 'emails/new_loan'=>'emails#new_loan'
  post 'emails/new_collateral'=>'emails#new_collateral'
  post 'emails/new_borrower'=>'emails#new_borrower'
  post 'emails/add_file'=>'emails#add_file'
  post 'emails/add_image'=>'emails#add_image'
  post 'emails/all_borrowers'=>'emails#all_borrowers'
  post 'emails/add_borrower'=>'emails#add_borrower'
  post 'emails/all_collaterals'=>'emails#all_collaterals'
  post 'emails/add_collateral'=>'emails#add_collateral'
  #post 'loans/get_url/:id'=>'loans#get_url'
  #post 'loans/reset_url/:id'=>'loans#reset_url'
  #get 'loans/reset_url/:id'=>'loans#reset_url'
  #post 'loans/nda'=>'loans#nda_signed'

  #get 'loans/temp/get_images'=>'loans#temp'

 
  post "payments/payment_successfull" => "payments#payment_successfull"
  get "payments/expand_memory" => "payments#expand_memory"
  post "payments/expand_memory_payment" => "payments#expand_memory_payment"
  get "payments/subscribe_plan" => "payments#subscribe_plan"
  post "payments/proceed_payment" => "payments#proceed_payment"
   get "payments/billing" => "payments#billing"
  get "payments/pdf_invoice/:id" => "payments#pdf_invoice"
  post "payments/payment_history" => "payments#payment_history"
  post "payments/next_payment" => "payments#next_payment"
  post "payments/change_billing_info" => "payments#change_billing_info"
  post "payments/change_info" => "payments#change_info"
  post "payments/select_plan" => "payments#select_plan"



  #admin links
  get 'admin' =>'admin#index'
  get "admin/new_user" => "admin#new_user", as: :admins_new_user
  post "admin/create_user" => "admin#create_user", as: :admins_create_user
  
  get "admin/edit_user/:id" => "admin#edit_user", as: :admins_edit_user
  patch "admin/edit_user/:id" => "admin#update_user", as: :admins_update_user
  delete "admin/destroy_user/:id" => "admin#destroy_user", as: :admins_destroy_user
  get "admin/subscribers" => "admin#subscribers"
   get "admin/settings" => "admin#settings"
   post "admin/update" => "admin#update"
   post "admin/delete_admins" => "admin#delete_admins"
   post "admin/check_email" => "admin#check_email"
    post "admin/check_uname" => "admin#check_uname"



  #routes for api calls to handle links in emails and campaign requests
  namespace :api do
    #resources :actions
    post '/match_lenders/:id/:token'=>'actions#match_lender'
    get '/shop_loan/:id/:token'=>'actions#shop_loan'
    get '/keep_loan/:id/:token'=>'actions#keep_loan'
    get '/indicate_interest/:id/:token'=>'actions#indicate_interest'
    get '/declined_interest/:id/:token'=>'actions#declined_interest'
    post '/manual_shop_loan/:id/:token'=>'actions#manual_shop_loan'

    mount Resque::Server, :at => "/resque"

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
