class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :confirmable,
         :email_regexp =>  /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :bio,
                  :full_name, :profession_and_degree, :role, :avatar, :specialization,
                  :birthday, :following_me, :following_published, :added_as_author,
                  :following_item,  :commented_item, :recommended_comment,
                  :following_bought_item, :item_changes, :educations, :educations_attributes

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
  has_many :items, through: :contributions
  has_many :pay_accounts, :dependent => :destroy
  has_many :educations, :dependent => :destroy

  accepts_nested_attributes_for :educations, :allow_destroy => true

  store :settings, accessors: [
        :following_me,          #Someone following me
        :following_published,   #Someone of my following has published something
        :added_as_author,       #Someone added you as a author of an item
        :following_item,        #Someone started following your item
        :commented_item,        #Someone commented on your item
        :recommended_comment,   #Someone recommended your comment
        :following_bought_item, #Someone you are following bought an item
        :item_changes           #Item you following as changed or updated (price, title, summary goes from paid to free and etc)
  ]

  validates :full_name, :length => { :minimum => 4, :maximum => 40 },
            :allow_blank => false
  validates :password, :confirmation => true,
            :unless => Proc.new { |a| a.password.blank? }
  validates :email, :uniqueness => true, :presence => true,
            :allow_blank => false
  validates :profession_and_degree, :length => { :minimum => 4, :maximum => 40 },
            :allow_blank => false, :unless => Proc.new { |a| a.role == "patient" }
  validates :role, :inclusion => %w(doctor patient moderator)
  validates :birthday, :date => {
            :after => Proc.new { Time.now - 100.year },
            :before => Proc.new { Time.now }
            }, :allow_blank => true, :on => :update

  mount_uploader :avatar, AvatarUploader

  default_value_for :role, 'doctor'

  fires :update_profile,  :on     => :update,
                          :actor  => :self

  scope :role_is, lambda {|role| where(:role => role)}

  define_index do
    indexes full_name, :sortable => true
    indexes specialization, :sortable => true
    #where sanitize_sql(["published", true])
    has created_at, updated_at
    set_property :enable_star => true
    set_property :min_infix_len => 1
  end

  def self.collaborators user
    find_by_sql "SELECT C.* FROM users as C
      JOIN contributions as B ON (C.id = B.contributor_id AND C.id <> #{user.id})
      JOIN contributions as A ON (B.item_id = A.item_id)
      WHERE A.contributor_id = #{user.id} GROUP BY B.contributor_id"
  end
end
