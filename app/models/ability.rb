# -*- coding: utf-8 -*-
class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new
    send( ('admin' if @user.admin?) || @user.role || 'guest')
  end

  def guest
    can :read, [ Item, Comment ] do |obj|
      owner_or_published?(obj)
    end
  end
  
  def patient
    guest
    can :read, [User, Item]
    can :update, User, :id => @user.id
    can [:follow, :unfollow, :upload_avatar], [User, Item]
    can :manage, Comment do |comment|
      owner_or_published?(item)
    end
  end

  def doctor
    patient
    # Item
    can :create, Item
    can [:update, :follow, :unfollow], Item do |item| 
      owner_or_published?(item)
    end
  end

  def moderator
    doctor
    can [:read, :update], [Item, Comment]
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
    obj.try(:published)
  end

  def owner_or_published?(obj)
    owner?(obj) ? true : published?(obj)
  end
end
