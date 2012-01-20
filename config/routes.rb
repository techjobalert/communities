Orthodontic::Application.routes.draw do

  resources :file, :only => [:index] do
    collection do
      post "upload", :action => 'upload'

      get "load/:name", :action => 'load', :constraints => { :name => /.*/ }

      post "convert/:name", :action => 'convert', :constraints => { :name => /.*/ }

      post "merge/:name/:name2", :action => 'merge', :constraints => { :name => /.*/, :name2 => /.*/ }
    end
  end

  #root :to => "challenges#index"
  match '/', :to => redirect('/startpage.html')
end