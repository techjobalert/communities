Orthodontic::Application.routes.draw do

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
    delete "delete"
  end

  resources :users, :only => [:create, :show, :edit, :update, :index], :path_names => { :edit => 'settings' } do
    post "upload_avatar"
    post "follow"
    post "send_message"
    post "send_message_to_followers"
    delete "unfollow"
  end

  resources :pay_accounts, :only => [:create, :update]

  get     'moderator'                      => 'moderator#items'
  get     'moderator/items/:id'            => 'moderator#item_show',        :as => :moderator_item
  get     'moderator/items/:id/confirm'    => 'moderator#item_publish',     :as => :confirm_moderator_item
  delete  'moderator/items/:id/deny'       => 'moderator#item_deny',        :as => :deny_moderator_item
  get     'moderator/comments'             => 'moderator#comments',         :as => :moderator_comments
  get     'moderator/comments/:id/confirm' => 'moderator#comment_publish',  :as => :confirm_moderator_comment
  delete  'moderator/comments/:id/deny'    => 'moderator#comment_deny',     :as => :deny_moderator_comment

  # Account
  match 'account/items'           => 'account#items',           :via => :get, :as => :items_account
  match 'account/purchase'        => 'account#purchase',        :via => :get, :as => :purchase_account
  match 'account/payments_info'   => 'account#payments_info',   :via => :get, :as => :payments_info_account
  match 'account/purchased_items' => 'account#purchased_items', :via => :get, :as => :purchased_items_account

  # Search logic
  match '/search'              => "search#index"
  match '/search/qsearch-item' => "search#qsearch_item"
  match '/search/qsearch-user' => "search#qsearch_user"

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
  # match "/sign_in"                => "pages#sign_in"
  # match "/item"                   => "pages#item"
  # match "/interesting_item"       => "pages#interesting_item"
  # match "/items_you_follow"       => "pages#items_you_follow"
  # match "/account"                => "pages#account"
  # match "/account_purchased_item" => "pages#account_purchased_item"
  # match "/user"                   => "pages#user"
  # match "/settings"               => "pages#settings"
  # match "/colleagues"             => "pages#colleagues"
  # match "/upload_page"            => "pages#upload"
  # match "/admin_page"             => "pages#admin"
  # ----------------------------------------------------------------------------
  # ----------------------------------------------------------------------------
  # ----------------------------------------------------------------------------
  # ----------------------------------------------------------------------------

end
