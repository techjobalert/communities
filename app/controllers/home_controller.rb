class HomeController < ApplicationController
  has_scope :filter_type do |controller, scope, value|
    value != "basic" ? scope.where(:user_id => controller.current_user.id) : scope
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
    collegues = ["followers", "published_together", "following", "patients"]
    _classes, @render_items  = Item, params[:filter_type]
    if collegues.include? params[:filter_type]
      _classes = User
      @tmp_folder = "users"
    elsif ["basic", "account"].include? params[:filter_type]
      _items = apply_scopes(Item.state_is("published"))
      @items = _items.page(params[:page]).per(3) if _items
    else
      @items = Item.state_is("published").page(params[:page])
    end
    if params[:q].present?
      @items = ThinkingSphinx.search("#{params[:q]}", :classes => [_classes])
        .page(params[:page]).per(3)
    end
  end

  def new_captcha
  end

end