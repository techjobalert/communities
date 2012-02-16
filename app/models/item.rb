class Item < ActiveRecord::Base
  include PubUnpub
  include SettingsHelper

  attr_accessible :title, :description, :tag_list, :paid, :user, :user_id
  validates :title, :description, :presence => true

  acts_as_commentable
	acts_as_taggable
  acts_as_followable
  
  # Scopes
  scope :published, where(:published => true)
  scope :unpublished, where(:published => false)
  scope :new_in_last_month, where(:created_at => ((Time.now.months_ago 1)..Time.now))

  # Handlers
  before_create  :default_values

  paginates_per 3

  belongs_to :user, :counter_cache => true
  
  fires :new_item,  :on                 => [:create, :update, :destroy],
                    :actor              => :user,
                    #implicit :subject  => self,
                    #:secondary_subject  => 'post',
                    :if => lambda { |item| item.published != false }

  define_index do
    indexes title, :sortable => true
    indexes description, :sortable => true
    indexes paid
    where sanitize_sql(["published", true])
    has user_id, created_at, updated_at
  end

  def default_values
    self.published = !get_setting("items_pre_moderation")
    true
  end
end