class Item < ActiveRecord::Base
  #include PubUnpub
  include SettingsHelper

  attr_accessible :title, :description, :tag_list, :paid, :user, :user_id,
                  :views_count, :amount, :price, :state, :moderated_at,
                  :approved_by, :attachments, :preview_length
  validates :title, :description, :presence => true

  acts_as_commentable
  acts_as_taggable
  acts_as_followable

  paginates_per 30

  # Scopes

  scope :state_is, lambda {|state| where(:state => state)}
  scope :published, where("state <> 'archived'").order("created_at DESC")
  scope :new_in_last_day, where(:created_at => (Date.today.to_time..Time.now))
  scope :new_in_last_week, where(:created_at => ((Time.now.weeks_ago 1)..Time.now))
  scope :new_in_last_month, where(:created_at => ((Time.now.months_ago 1)..Time.now))
  scope :new_in_last_year, where(:created_at => ((Time.now.years_ago 1)..Time.now))
  scope :paid, where("price != 0")
  scope :free, where(:price => 0 )
  scope :by_user, lambda{ |user| where("user_id = ?", user.id) }
  scope :purchased, where("amount != 0")
  scope :content_type, lambda {|attachment_type| where(:attachment_type => attachment_type)}

  # Handlers
  before_create  :add_to_contributors

  belongs_to  :user, :counter_cache => true, class_name: :User, inverse_of: :items
  belongs_to  :approved_by, class_name: :User, :foreign_key => "approved_by"

  has_many    :comments, :dependent => :destroy, :as => :commentable
  has_many    :orders
  has_many    :contributions, :order => 'created_at ASC'
  has_many    :contributors, through: :contributions
  has_many    :attachments, :dependent => :destroy
  has_many    :presenter_videos, :dependent => :destroy

  accepts_nested_attributes_for :attachments

  # fires :created_item,    :on     => :create,
  #                         :actor  => :user

  fires :published_item,  :on     => :update,
                          :actor  => :user,
                          :secondary_subject => :self,
                          :if => lambda { |item| item.state == "published" and item.moderated_at > (Time.zone.now() - 10.second) }

  # fires :destroyed_item,  :on     => :destroy,
  #                         :actor  => :user

  state_machine :state, :initial => :draft do

    before_transition :on => :publish do |item|
      item.number_of_updates += 1
    end

    after_transition :on => :publish do |item|
      Resque.enqueue(CreatePreview, item.id, item.preview_length) if item.paid?
    end

    event :edit do
      transition [:denied, :published, :moderated] => :draft
    end

    event :moderate do
      transition [:denied, :draft, :published] => :moderated
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
    has "CRC32(state)", :as => :state, :type => :integer
    has "CRC32(attachment_type)", :as => :attachment_type, :type => :integer
    has price, :type => :integer
    has taggings.tag_id, :as => :tag_ids
    # has "CRC32(tags.name)", :as => :tags, :type => integer
    # where "state = 'published'"
    set_property :enable_star => true
    set_property :min_infix_len => 1
    set_property :delta => true
  end

  def paid?
    price > 0
  end

  def purchased?(user)
    order = self.orders.where("user_id = ? AND state = ?", user.id, "paid")
    order.present?
  end

  def common_video
    presenter_merged_video or regular_video
  end

  def presenter_merged_video
    attachments.select{|a| a.is_processed_to_video? && a.attachment_type == "presenter_merged_video"}.last
  end

  def presenter_video
    attachments.select{|a| a.is_processed_to_video? && a.attachment_type == "presenter_video"}.last
  end

  def regular_video
    attachments.select{|a| a.is_processed_to_video? && %w(video presentation_video regular).member?(a.attachment_type)}.last
  end

  def regular_pdf
    attachments.select{|a| a.is_pdf? or a.is_processed_to_pdf? }.last
  end

  def attachment_thumb

    attachment = self.attachments.select{|a| a != "presenter_video"}.last

    if attachment.present? and attachment.file.present?
      attachment.get_thumbnail
    else
      "/assets/default/item_thumb_default.png"
    end
  end

  def paid_view?(user)
    if (paid? and purchased?(user)) or (!paid?) or self.user == user or user.admin?
      (%w(presentation video).member?(attachment_type)) ? common_video : regular_pdf
    else
      attachments.where("attachment_type like ?", '%preview%').last
    end
  end

  def can_get_pdf?(user)
    ((paid? and purchased?(user)) or (!paid? and published?) or self.user == user or user.admin?) and (attachment_type == "article")
  end

end
