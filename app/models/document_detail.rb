class DocumentDetail < ActiveRecord::Base
  attr_accessible :attachment_id, :page_count, :page_height, :page_width
end
