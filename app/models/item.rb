class Item < ActiveRecord::Base
  include PubUnpub
  include SettingsHelper

  attr_accessible :title, :description, :tag_list, :paid, :user, :user_id,
    :views_count, :deleted, :amount, :price
  validates :title, :description, :presence => true

  acts_as_commentable
	acts_as_taggable
  acts_as_followable

  # Scopes
  scope :published, where(:published => true).order("created_at DESC")
  scope :unpublished, where(:published => false)
  scope :new_in_last_month, where(:created_at => ((Time.now.months_ago 1)..Time.now))

  default_scope where(:deleted => false)

  # Handlers
  before_create   :default_values, :add_to_contributors

  paginates_per 3

  belongs_to  :user, :counter_cache => true, class_name: :User, inverse_of: :items
  # belongs_to  :creator, class_name: :User, inverse_of: :items

  has_many    :comments, :dependent => :destroy
  has_many    :contributions
  has_many    :contributors, through: :contributions

  fires :created_item,    :on     => :create,
                          :actor  => :user

  fires :updated_item,    :on     => :update,
                          :actor  => :user

  fires :destroyed_item,  :on     => :destroy,
                          :actor  => :user

  define_index do
    indexes :title,          :sortable => true
    indexes :description,    :sortable => true
    indexes user.full_name,  :sortable => true
    indexes tags.name
    has user_id, created_at
    set_property :enable_star => true
    set_property :min_infix_len => 1
  end

  def add_to_contributors
    self.contributors << user
  end

  def default_values
    self.published = !get_setting("items_pre_moderation")
    true
  end
end
