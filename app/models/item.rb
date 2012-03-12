class Item < ActiveRecord::Base
  #include PubUnpub
  include SettingsHelper

  attr_accessible :title, :description, :tag_list, :paid, :user, :user_id,
    :views_count, :amount, :price, :state, :moderated_at
  validates :title, :description, :presence => true

  acts_as_commentable
	acts_as_taggable
  acts_as_followable

  paginates_per 3

  # Scopes

  scope :state_is, lambda {|state| where(:state => state)}
  scope :published, where("state <> 'archived'").order("created_at DESC")
  scope :new_in_last_day, where(:created_at => (Date.today.to_time..Time.now))
  scope :new_in_last_week, where(:created_at => ((Time.now.weeks_ago 1)..Time.now))
  scope :new_in_last_month, where(:created_at => ((Time.now.months_ago 1)..Time.now))
  scope :new_in_last_year, where(:created_at => ((Time.now.years_ago 1)..Time.now))
  scope :paid, where("price != 0")
  scope :free, where(:price => 0 )

  # Handlers
  before_create  :add_to_contributors

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

  state_machine :state, :initial => :moderated do
    # after_transition :on => :publish do |item|
    #   if self.user.has_attribute?(_get_counter_name)
    #     self.user[_get_counter_name] +=1
    #     self.user.save!
    #   end
    # end

    event :moderate do
      transition [:denied, :published] => :moderated
    end

    event :publish do
      transition :moderated => :published
    end

    event :archive do
      transition all => :archived
    end

    event :deny do
      transition [:moderated, :published] => :denied
    end
  end

  def add_to_contributors
    self.contributors << user
  end

  define_index do
    indexes title,           :sortable => true
    indexes description,     :sortable => true
    indexes user.full_name,  :as => :author, :facet => true, :sortable => true
    has user_id, created_at, views_count
    has price, :type => :integer
    has taggings.tag_id, :as => :tag_ids
    # has "CRC32(tags.name)", :as => :tags, :type => integer
    where "state = 'published'"
    set_property :enable_star => true
    set_property :min_infix_len => 1
  end

end
