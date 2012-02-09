Orthodontic::Application.routes.draw do

  get "home/index"

  #devise_for :users
  devise_for :users, :controllers => { :registrations => "registrations" }
  
  
  match "/sign_in" => "pages#sign_in"
  match "/item" => "pages#item"
  match "/interesting_item" => "pages#interesting_item"
  match "/items_you_follow" => "pages#items_you_follow"
  match "/account" => "pages#account"
  match "/account_purchased_item" => "pages#account_purchased_item"
  match "/user" => "pages#user"
  match "/settings" => "pages#settings"
  match "/colleagues" => "pages#colleagues"
  match "/upload_page" => "pages#upload"
  match "/admin_page" => "pages#admin"

  resources :file, :only => [:index] do
    collection do
      post "upload", :action => 'upload_psource'
      get "converted_pvideo", :action => 'converted_pvideo'

      get "webrecorder", :action => 'webrecorder'

      post "convert/:name", :action => 'convert', :constraints => { :name => /.*/ }

      post "merge", :action => 'merge'
    end
  end

  root :to => "home#index"
end
