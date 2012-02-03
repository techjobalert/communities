Orthodontic::Application.routes.draw do

  match "/home" => "pages#home"
  match "/item" => "pages#item"
  match "/interesting_item" => "pages#interesting_item"
  match "/items_you_follow" => "pages#items_you_follow"

  resources :file, :only => [:index] do
    collection do
      post "upload", :action => 'upload'

      get "load/:name", :action => 'load', :constraints => { :name => /.*/ }

      post "convert/:name", :action => 'convert', :constraints => { :name => /.*/ }

      post "merge", :action => 'merge'
    end
  end

  root :to => "file#index"
end
