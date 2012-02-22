class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, 
         :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, 
                  :full_name, :profession_and_degree, :role, :avatar, :specialization, :bio,
                  :birthday, :settings
    
  acts_as_followable
  acts_as_follower
  acts_as_voter

  #has_many :items, :dependent => :destroy
  has_many :comments, :as => :commentable, :dependent => :destroy

  has_many :contributions, foreign_key: :contributor_id
  has_many :items, through: :contributions
  
  has_many :pay_accounts, :dependent => :destroy
  
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

  validates :full_name, :role, :presence => true
  validates :role, :inclusion => %w(doctor patient moderator)
  validates :birthday, :date => { 
            :after => Proc.new { Time.now - 100.year }, 
            :before => Proc.new { Time.now }
            }, :allow_blank => true, :on => :update
  
  mount_uploader :avatar, AvatarUploader
  
  default_value_for :role, 'doctor'

  fires :update_profile,  :on     => :update,
                          :actor  => :self,
                          :if => lambda { |user| user.signed_in? }

  scope :role_is, lambda {|role| where(:role => role)}

  define_index do
    indexes full_name, :sortable => true
    indexes specialization, :sortable => true
    #where sanitize_sql(["published", true])
    has created_at, updated_at
  end

  def method_missing(method_name, *args)
    if method_name =~ /^settings_(\w+)$/
      settings[$1.to_sym]
      #self.all(:conditions => {$1 => args[0]})
    end
  end
  
end