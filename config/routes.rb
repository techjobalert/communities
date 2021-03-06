Orthodontic::Application.routes.draw do
  get "widgets/index"

  get "widgets/communities"

  #get "community/index"

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # mount ImperaviRails::Engine => "/imperavi"

  devise_for :users, :controllers => {
    :registrations => "registrations", :sessions => "sessions", :passwords => "passwords",
    :omniauth_callbacks => "omniauth_callbacks"
  }

  devise_scope :user do
    match '/confirm/:confirmation_token', :to => "devise/confirmations#show", :as => "user_confirm", :only_path => false
  end

  resources :orders, :only => :create do
    post  "verification"          => "orders#card_verification",      :as => :card_verification,      :on => :collection
    post  "create_transaction"    => "orders#create_transaction",     :as => :create_transaction,     :on => :collection
  end

  resources :items do
    resources :comments do
      get   "vote_up"
    end
    post    "follow"
    delete  "unfollow"
    delete  "delete"
    delete  "delete_from_contributors"
    post    "add_to_contributors"
    put     "change_price"
    get     "relevant"
    put     "change_keywords"
    get     "users_search"
    get     "pdf_page"
    get     "search",             :on => :collection
    get     "qsearch",            :on => :collection
    get     "tags",               :on => :collection
    post    "upload_attachment",  :on => :collection
    post    "merge_presenter_video"
    get     "get_attachment"
    get     "following",          :on => :collection
    put     "update_preview"
  end

  resources :users, :only => [:create, :show, :edit, :update, :index], :path_names => { :edit => 'settings' } do
    post    "upload_avatar"
    post    "upload_avatar/crop" => 'users#crop_avatar'
    post    "follow"
    post    "send_message"
    post    "send_message_to_colleagues"
    delete  "unfollow"
    get     "search", :on => :collection
  end

  get   'moderator'                      => 'moderator#items'
  get   'moderator/items/:id'            => 'moderator#item_show',        :as => :moderator_item
  get   'moderator/items/:id/confirm'    => 'moderator#item_publish',     :as => :confirm_moderator_item
  post  'moderator/items/:id/deny'       => 'moderator#item_deny',        :as => :deny_moderator_item
  get   'moderator/comments'             => 'moderator#comments',         :as => :moderator_comments
  get   'moderator/comments/:id/confirm' => 'moderator#comment_publish',  :as => :confirm_moderator_comment
  get   'moderator/comments/:id/deny'    => 'moderator#comment_deny',     :as => :deny_moderator_comment

  # Account
  match 'account/items'           => 'account#items',           :via => :get, :as => :items_account
  match 'account/purchase'        => 'account#purchase',        :via => :get, :as => :purchase_account
  match 'account/payments_info'   => 'account#payments_info',   :via => :get, :as => :payments_info_account
  match 'account/purchased_items' => 'account#purchased_items', :via => :get, :as => :purchased_items_account
  match 'account/get_contacts'    => 'account#get_contacts',    :via => :get, :as => :get_contacts
  match 'account/find_contacts'   => 'account#find_contacts',   :via => :get, :as => :find_contacts
  match 'account/send_invites'    => 'account#send_invites',    :via => :post, :as => :send_invites

  # Search logic
  match '/search'              => "search#index"
  match '/search/qsearch-item' => "search#qsearch_item"
  match '/search/qsearch-user' => "search#qsearch_user"

  # Captcha refresh
  match '/captcha_refresh' => "home#new_captcha"

  # Rendering json for articles
  match 'items/:id/attachments/:attachment_id/get_pdf_json' => "items#get_pdf_json", :via => :get, :as => :get_pdf_json

  # Static pages
  match '/orthodontic_sale' => "home#orthodontic_sale"

  resources :file, :only => [:index] do
    collection do
      post "upload",            :action => 'upload_psource'
      get  "converted_pvideo",  :action => 'converted_pvideo'
      get  "webrecorder",       :action => 'webrecorder'
      post "convert/:name",     :action => 'convert', :constraints => {:name => /.*/ }
      post "merge",             :action => 'merge'
    end
  end

  # match "/uploads/attachment/file/:file_id/:basename.:extension",
  #   :controller => "items",
  #   :action => "get_attachment",
  #   :via => :get,
  #   :constraints => { :extension => /(pdf|webm|mp4)/ }

  root :to => "home#index"
  mount Resque::Server, at: "/resque"

  resources :communities, :only => :show
  

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
