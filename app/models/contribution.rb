class Contribution < ActiveRecord::Base
  belongs_to :contributor, class_name: :User
  belongs_to :item

  fires :added_to_authors,
        :on                 => :create,
        :actor              => :contributor,
        :secondary_subject  => :item

  fires :removed_from_authors,
        :on                => :destroy,
        :actor             => :contributor,
        :secondary_subject => :item
end
