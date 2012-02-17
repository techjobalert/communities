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
  before_create   :default_values
  after_create    :after_create_handler

  paginates_per 3

  belongs_to  :user, :counter_cache => true
  has_many    :comments

  fires :create_item,  :on                 => :create,
                       :actor              => :user

  fires :update_item,  :on                 => :update,
                       :actor              => :user

  fires :destroy_item, :on                 => :destroy,
                       :actor              => :user

  define_index do
    indexes title,          :sortable => true
    indexes description,    :sortable => true
    indexes user.full_name, :sortable => true
    indexes paid
    where sanitize_sql(["published", true])
    has user_id, created_at, updated_at
  end

  def after_create_handler
    p self
  end
  def default_values
    self.published = !get_setting("items_pre_moderation")
    p !get_setting("items_pre_moderation")
    p self.published
    true
  end
end