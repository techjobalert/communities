class Item < ActiveRecord::Base
  #include PubUnpub
  include SettingsHelper

  attr_accessible :title, :description, :tag_list, :paid, :user, :user_id,
                  :views_count, :amount, :price, :state, :moderated_at,
                  :approved_by, :attachments, :preview_length
  validates :title, :description, :presence => true
  #validate :preview_length_validation, :on => :update

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
  before_create :add_to_contributors
  around_update :update_preview, :if => :preview_length_changed?
  before_destroy :set_user_delta_flag, :if => Proc.new {|item| item.state == 'published' }

  belongs_to  :user, :counter_cache => true, class_name: :User, inverse_of: :items
  belongs_to  :approved_by, class_name: :User, :foreign_key => "approved_by"

  has_many    :comments, :dependent => :destroy, :as => :commentable
  has_many    :orders
  has_many    :contributions, :order => 'created_at ASC'
  has_many    :contributors, through: :contributions
  has_many    :attachments, :dependent => :destroy, :before_add => :update_preview
  has_many    :presenter_videos, :dependent => :destroy
  has_many    :follows, :as => :followable, :conditions => {:blocked => false}

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

    # after_transition :on => :moderate do |item|
    #   Resque.enqueue(CreatePreview, item.id, item.preview_length) if item.paid?
    # end

    after_transition :on => :moderate do |item|
      Resque.enqueue(SendProcessedMessage, item.id) if item.processed?
    end

    after_transition any => :published do |item|
      item.set_user_delta_flag
    end

    after_transition :published => any - :published do |item|
      item.set_user_delta_flag
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
    has follows.follower_id, :as => :follower_ids
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

  def processed?
    self.attachments.map(&:file_processing).compact.empty?
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

    if attachment.present? 
      if attachment.file.present?
        attachment.get_thumbnail
      else
        "/assets/default/item_thumb_default.png"
      end
    else
      "/assets/default/item_thumb_no_file.png"
    end
  end

  def owner? user
    self.user == user
  end

  def paid_view?(user)
    if attachment_type != 'article'
      return common_video unless paid?

      return attachments.where("attachment_type like ?", '%preview%').last unless user

      if (paid? and purchased?(user)) or owner?(user) or user.admin?      
        common_video
      else
        attachments.where("attachment_type like ?", '%preview%').last
      end
    else
      regular_pdf
    end
  end

  def can_get_pdf?(user)
    ((paid? and purchased?(user)) or (!paid? and published?) or self.user == user or user.admin?) and (attachment_type == "article")
  end

  def self.users_by_count(count)
    state_is('published').group('user_id').count.select{|key,value| value == count}.keys
  end

  def set_user_delta_flag
    self.user.delta = true
    self.user.save
  end

  private

  def update_preview

    if self.attachments.any?
      if self.paid? && self.attachment_type.match(/video/)
        last_attachment = self.attachments.where(:attachment_type => "#{self.attachment_type}_preview").last
        if last_attachment && last_attachment.file_processing
          self.errors.add(:preview_length,"can't change preview length before current preview file processing")
          return false
        else
          if last_attachment
            last_attachment.destroy 
          end  
          yield
          Resque.enqueue(CreatePreview, self.id, self.preview_length)
        end
      else
        yield
      end
    else
      yield
    end

  end
end
