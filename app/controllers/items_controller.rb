class ItemsController < InheritedResources::Base
  before_filter :authenticate_user!, :except => [:show, :index]
  load_and_authorize_resource
end
