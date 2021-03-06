class Comment < ActiveRecord::Base
  #include PubUnpub
  include SettingsHelper

  acts_as_nested_set :scope => [:commentable_id, :commentable_type]

  validates_presence_of :body
  validates_presence_of :user

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  acts_as_votable

  # NOTE: Comments belong to a user
  belongs_to :user, :counter_cache => true
  belongs_to :item, :counter_cache => true

  belongs_to :commentable, :polymorphic => true
  has_many :comments, :as => :commentable

  # Scopes
  scope :state_is, lambda {|state| where(:state => state)}
  scope :new_in_last_month, where(:created_at => ((Time.now.months_ago 1)..Time.now))
  default_scope order('comments.created_at DESC')
  # Handlers
  # before_create  :default_values

  state_machine :state, :initial => :moderated do
    event :publish do
      transition :moderated => :published
    end
  end

  # Helper class method that allows you to build a comment
  # by passing a commentable object, a user_id, and comment text
  # example in readme
  def self.build_from(obj, user_id, comment)
    c = self.new
    c.commentable_id = obj.id
    c.commentable_type = obj.class.name
    c.body = comment
    c.user_id = user_id
    c
  end

  fires :created_comment,  :on                 => :create,
                           :actor              => :user,
                           :secondary_subject  => :commentable

  #helper method to check if a comment has children
  def has_children?
    self.children.size > 0
  end

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  scope :find_comments_by_user, lambda { |user|
    where(:user_id => user.id).order('created_at DESC')
  }

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  scope :find_comments_for_commentable, lambda { |commentable_str, commentable_id|
    where(:commentable_type => commentable_str.to_s, :commentable_id => commentable_id).order('created_at DESC')
  }

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  # def default_values
  #   self.published = !get_setting("comments_pre_moderation")
  #   true
  # end
end
