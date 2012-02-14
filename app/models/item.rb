class Item < ActiveRecord::Base
	acts_as_commentable
	acts_as_taggable
  
  define_index do
    indexes title, :sortable => true
    indexes description, :sortable => true
    indexes paid
    where sanitize_sql(["published", true])
    has user_id, created_at, updated_at
  end

end