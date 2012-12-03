# -*- coding: utf-8 -*-
Dir["#{Rails.root}/lib/google_modules/*.rb"].each {|file| require file }
class User < ActiveRecord::Base
  include GmailContactsApi
  include GmailTokensApi
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :confirmable, :recoverable, :omniauthable,
         :email_regexp =>  /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :bio,
                  :full_name, :profession_and_degree, :role, :avatar, :specialization,
                  :birthday, :educations, :educations_attributes, :admin, :paypal_account, 
                  :communities, :community_ids,

                  # Settings
                  :following_me, :following_published, :added_as_author,
                  :following_item, :commented_item, :recommended_comment,
                  :following_bought_item, :item_changes, :show_bio,
                  :show_birthday, :show_educations,

                  # Avatar Settings
                  :crop_x, :crop_y, :crop_h, :crop_w

  acts_as_followable
  acts_as_follower
  acts_as_voter

  #has_many :items, :dependent => :destroy
  has_many :comments, :as => :commentable, :dependent => :destroy
  
  has_many :messages_sended, :class_name => 'Message',
           :dependent => :destroy, foreign_key: :user_id
           
  has_many :messages_received, :class_name => 'Message',
           :dependent => :destroy, foreign_key: :receiver_id,
            inverse_of: :user

  has_many :contributions, foreign_key: :contributor_id
  has_many :contibution_items, through: :contributions
  has_many :items
  has_many :approvals, class_name: :Item, :foreign_key => "approved_by"
  has_many :educations, :dependent => :destroy
  has_many :orders
  has_many :attachments, :dependent => :destroy
  has_many :presenter_videos, :dependent => :destroy
  has_many :follower_users, :class_name => 'Follow', :as => :followable,
    :conditions => {:blocked => false, :follower_type => 'User'}
  has_many :following_users, :class_name => 'Follow', :as => :follower,
    :conditions => {:blocked => false, :followable_type => 'User'}

  has_many :published_items, :class_name => 'Item', :conditions => {:state => 'published'}
  has_one :social_account_credential

  has_and_belongs_to_many :communities
  accepts_nested_attributes_for :communities
  
  accepts_nested_attributes_for :educations, :allow_destroy => true

  
  store :settings, accessors: [
        :following_me,          #Someone following me
        :following_published,   #Someone of my following has published something
        :added_as_author,       #Someone added you as a author of an item
        :following_item,        #Someone started following your item
        :commented_item,        #Someone commented on your item
        :recommended_comment,   #Someone recommended your comment
        :following_bought_item, #Someone you are following bought an item
        :item_changes,          #Item you following as changed or updated (price, title, summary goes from paid to free and etc)
        # Privacy settings
        :show_bio,
        :show_educations,
        :show_birthday
  ]

  store :avatar_settings, accessors: [
        :crop_x,
        :crop_y,
        :crop_h,
        :crop_w
  ]

  validates :full_name, :length => { :minimum => 3, :maximum => 40 },
            :allow_blank => false
  validates_format_of :full_name, :with=> /\A[а-яА-Яa-zA-Z0-9_\.\-\s]+\Z/u,
                      :allow_blank => false,
                      :message => "Wrong name format"

  validates :password, :confirmation => true,
            :unless => Proc.new { |a| a.password.blank? }
  validates :email, :presence => true, :allow_blank => false #,:uniqueness => true
  #validates :profession_and_degree, :length => { :minimum => 2, :maximum => 40 },
  #          :allow_blank => false, :unless => Proc.new { |a| a.role == "patient" }
  validates :role, :inclusion => %w(doctor patient moderator)
  validates :birthday, :date => {
            :after => Proc.new { Time.now - 100.year },
            :before => Proc.new { Time.now } },
            :allow_blank => true, :on => :update

  mount_uploader :avatar, AvatarUploader

  default_value_for :role, 'doctor'

  # fires :update_profile,  :on     => :update,
  #                         :actor  => :self

  scope :role_is, lambda {|role| where(:role => role)}
  scope :take_random, lambda {|c| where(:id => all.map(&:id).shuffle.take(c))}

  after_initialize :init_default_settings, :if => :new_record?

  # after_save :reprocess_avatar, :if => :cropping?

  def self.collaborators user
    find_by_sql "SELECT C.* FROM users as C
      JOIN contributions as B ON (C.id = B.contributor_id AND C.id <> #{user.id})
      JOIN contributions as A ON (B.item_id = A.item_id)
      WHERE A.contributor_id = #{user.id} GROUP BY B.contributor_id"
  end

  def role?(name)
    role == name
  end

  def self.degrees
    role_is('doctor').select(:profession_and_degree).uniq.map(&:profession_and_degree).compact
  end

  def self.specializations
    role_is('doctor').select(:specialization).uniq.map(&:specialization).compact
  end

  define_index do
    indexes full_name, :sortable => true
    has "CRC32(specialization)", :as => :specialization, :type => :integer
    has "CRC32(profession_and_degree)", :as => :degree, :type => :integer
    has following_users.followable_id, :as => :following_ids
    has follower_users.follower_id, :as => :follower_ids
    has "CRC32(role)", :as => :role, :type => :integer
    has :id
    # indexes role
    has created_at, updated_at
    set_property :enable_star => true
    set_property :min_infix_len => 1
    set_property :delta => true
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end


  def get_google_activities
    google_apikey = 'AIzaSyBB59WRddUJKSwa-7RQvuEMSiMZuTIzj1c'
    google_user_id = social_account_credential.google_user_id
    feed = RestClient.get("https://www.googleapis.com/plus/v1/people/#{google_user_id}/activities/public?alt=json&maxResults=50&key=#{google_apikey}").body

    if feed && feed["error"]
      feed = nil
      user_social_account_credential.update_attributes(:google_token  => nil);
    end

    feed
  end

  def google_token
    social_account_credential.google_token
  end

  def google_refresh_token
    social_account_credential.google_refresh_token
  end

  def google_user_id
    social_account_credential.google_user_id
  end


  private

  
  def get_communities
    
  end

  #   def reprocess_avatar
  #     self.avatar.recreate_versions!
  #   end

    def init_default_settings
      self.following_me = true
      self.following_published = true
      self.added_as_author = true
      self.following_item = true
      self.commented_item = true
      self.recommended_comment = true
      self.following_bought_item = true
      self.item_changes = true

      self.show_bio = true
      self.show_educations = true
      self.show_birthday = true
    end

end