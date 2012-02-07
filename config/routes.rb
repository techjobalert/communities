Orthodontic::Application.routes.draw do

  match "/home" => "pages#home"
  match "/sign_in" => "pages#sign_in"
  match "/item" => "pages#item"
  match "/interesting_item" => "pages#interesting_item"
  match "/items_you_follow" => "pages#items_you_follow"
  match "/account" => "pages#account"
  match "/account_purchased_item" => "pages#account_purchased_item"
  match "/user" => "pages#user"
  match "/settings" => "pages#settings"

  resources :file, :only => [:index] do
    collection do
      post "upload", :action => 'upload_psource'
      post "convert", :action => 'converted_pvideo'

      get "webrecorder", :action => 'webrecorder'

      post "convert/:name", :action => 'convert', :constraints => { :name => /.*/ }

      post "merge", :action => 'merge'
    end
  end

  root :to => "file#webrecorder"
end
