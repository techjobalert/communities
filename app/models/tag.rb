class Tag < ActiveRecord::Base
  scope :take_random, lambda {|c| where(:id => all.map(&:id).shuffle.take(c))}
end
