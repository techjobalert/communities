# -*- coding: utf-8 -*-
class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new
    send( ('admin' if @user.admin?) || @user.role || 'guest')
  end

  def guest
    can :read, [ Item, Comment ] do |obj|
      published?(obj)
    end
  end

  def patient
    guest
    can [:read, :search], User
    can :update, User, :id => @user.id
    can [:follow, :unfollow], [User, Item]
    can [:follow, :upload_avatar, :send_message], [User]
    can [:purchase,:payments_info], :account
  end

  def doctor
    patient
    # Item
    can :create, Item
    can :create, Comment
    can [:send_message_to_followers], [User]
    can [:read], Item do |item|
      owner_or_published?(item)
    end
    can :manage, [Comment, Item] do |obj|
      owner?(obj)
    end
    can [:items, :purchased_items], :account
    can [:add_to_contributors, :delete_from_contributors, :users_search], Item do |item|
      owner?(item)
    end
  end

  def moderator
    doctor
    can :update, [Item, Comment]
    can :all, :moderators
  end

  def admin
    moderator
    can :manage, :all
  end

private
  def owner?(obj)
    obj.try(:user) == @user
  end

  def published?(obj)
    obj.published?
  end

  def owner_or_published?(obj)
    owner?(obj) ? true : published?(obj)
  end
end
