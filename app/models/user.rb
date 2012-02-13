class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, 
    :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, 
    :full_name, :profession_and_degree, :role, :avatar, :specialization, :bio,
    :birthday
  
  validates :full_name, :role, :presence => true
  validates :role, :inclusion => %w(doctor patient)
  validates :birthday, :date => {
      :after => Proc.new { Time.now - 100.year }, 
      :before => Proc.new { Time.now }}
  
  default_value_for :role, 'doctor'
  
  mount_uploader :avatar, AvatarUploader
end
