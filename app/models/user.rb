class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, 
    :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, 
    :full_name, :profession_and_degree, :role, :avatar, :specialization, :bio,
    :birthday
  
  validates :full_name, :role, :presence => true
  validates :role, :inclusion => %w(doctor patient)

  validates :birthday, :date => {
            :after => Proc.new { Time.now - 100.year }, 
            :before => Proc.new { Time.now }
            }, :allow_blank => true, :on => :update
  
  default_value_for :role, 'doctor'
  
  mount_uploader :avatar, AvatarUploader

  define_index do
    indexes full_name, :sortable => true
    indexes specialization, :sortable => true
    #where sanitize_sql(["published", true])
    has created_at, updated_at
  end

  has_many :items
  
end
