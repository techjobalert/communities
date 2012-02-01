Orthodontic::Application.routes.draw do

  match "/home" => "pages#home"
  match "/inner" => "pages#inner"

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
