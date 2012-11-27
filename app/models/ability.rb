# -*- coding: utf-8 -*-
class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new
    send( ('moderator' if @user.admin?) || @user.role || 'guest')
  end

  def guest
    can :read, [ Item, Comment ] do |obj|
      published?(obj)
    end
  end

  def patient
    guest
    can :read, User
    can [:create, :create_transaction, :card_verification], Order
    can [:search, :qsearch], [User, Item]
    can :update, User, :id => @user.id
    can [:follow, :unfollow], [User, Item]
    can [:follow, :upload_avatar, :crop_avatar, :send_message], User
    can [:relevant, :following], Item
    can [:purchase,:payments_info, :get_contacts], :account
    can :read, [ Item, Comment ] do |obj|
      owner_or_published?(obj)
    end
  end

  def doctor
    patient

    can :create, Item
    can :create, Comment
    can :send_message_to_followers, User
    can :read, Item do |item|
      owner_or_published?(item)
    end
    can :manage, [Comment, Item] do |obj|
      owner?(obj)
    end

    can [:items, :purchased_items], :account
    can [ :add_to_contributors,
          :delete_from_contributors,
          :users_search,
          :change_price,
          :merge_presenter_video], Item do |item|
      owner?(item)
    end
  end

  def moderator
    doctor
    can :change_keywords, Item
    can [:items, :item_show, :item_publish, :item_deny, :comments, :comment_publish, :comment_deny], :moderator
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
