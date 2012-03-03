class HomeController < ApplicationController
  has_scope :filter_type do |controller, scope, value|
    scope.where(:user_id => controller.current_user.id) if value != "basic"
  end
  has_scope :page, :default => 1
  has_scope :length do |controller, scope, value|
    value.include?("Any") ? scope : scope
  end
  has_scope :date do |controller, scope, value|
    if value.include?("Any")
      scope
    else
      case value
      when "Today"
        scope.new_in_last_day
      when "1 Week"
        scope.new_in_last_week
      when "1 Month"
        scope.new_in_last_month
      when "1 Year"
        scope.new_in_last_year
      end
    end
  end
  has_scope :price do |controller, scope, value|
    if value.include?("Any")
      scope
    else
      case value
      when "Free"
        scope.free
      when "Paid"
        scope.paid
      end
    end
  end
  has_scope :views do |controller, scope, value|
    if value.include?("Any")
      scope
    else
      case value
      when "More Viewed"
        scope.order("views_count DESC")
      when "Less Viewed"
        scope.order("views_count ASC")
      end
    end
  end

  def index
    if params[:q].present?
      @items = ThinkingSphinx.search("#{params[:q]}", :classes => [Item])
        .page(params[:page]).per(3)
    elsif params[:filter_type]
      _items = apply_scopes(Item.state_is("published"))
      @items = _items.page(params[:page]).per(3) if _items
      @render_items = params[:filter_type]
    else
      @items = Item.state_is("published").page(params[:page])
    end
  end

  def new_captcha
  end
end