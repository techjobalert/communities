Orthodontic::Application.routes.draw do

  #get "account/items"

  #get "account/purchase"

  #get "account/purchased_items"

  #get "account/payments_info"

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  mount ImperaviRails::Engine => "/imperavi"

  devise_for :users, :controllers => { 
    :registrations => "registrations", :sessions => "sessions"}

  devise_scope :user do
    match '/confirm/:confirmation_token', :to => "devise/confirmations#show", :as => "user_confirm", :only_path => false
  end

  resources :items do
    resources :comments do
      get "vote_up"
    end
    post "follow"
    delete "unfollow"
  end

  resources :users, :only => [:create, :show, :edit, :update, :index], :path_names => { :edit => 'settings' } do
    post "upload_avatar"
    post "follow"
    post "send_message"
    post "send_message_to_followers"
    delete "unfollow"    
  end

  # Account
  match 'account/items'           => 'account#items',           :via => :get, :as => :items_account
  match 'account/purchase'        => 'account#purchase',        :via => :get, :as => :purchase_account
  match 'account/payments_info'   => 'account#payments_info',   :via => :get, :as => :payments_info_account
  match 'account/purchased_items' => 'account#purchased_items', :via => :get, :as => :purchased_items_account


  # Search logic
  match '/search'         => "search#index"
  match '/search/qsearch' => "search#qsearch"

  # Captcha refresh
  match '/captcha_refresh' => "home#new_captcha"

  resources :file, :only => [:index] do
    collection do
      post "upload",          :action => 'upload_psource'
      get "converted_pvideo", :action => 'converted_pvideo'
      get "webrecorder",      :action => 'webrecorder'
      post "convert/:name",   :action => 'convert', :constraints => {:name => /.*/ }
      post "merge",           :action => 'merge'
    end
  end

  root :to => "home#index"


  # ----------------------------------------------------------------------------
  # ----------------------------------------------------------------------------
  # ----------------------------------------------------------------------------
  # ----------------------------------------------------------------------------
  match "/sign_in"                => "pages#sign_in"
  match "/item"                   => "pages#item"
  match "/interesting_item"       => "pages#interesting_item"
  match "/items_you_follow"       => "pages#items_you_follow"
  match "/account"                => "pages#account"
  match "/account_purchased_item" => "pages#account_purchased_item"
  match "/user"                   => "pages#user"
  match "/settings"               => "pages#settings"
  match "/colleagues"             => "pages#colleagues"
  match "/upload_page"            => "pages#upload"
  match "/admin_page"             => "pages#admin"
  # ----------------------------------------------------------------------------
  # ----------------------------------------------------------------------------
  # ----------------------------------------------------------------------------
  # ----------------------------------------------------------------------------

end
