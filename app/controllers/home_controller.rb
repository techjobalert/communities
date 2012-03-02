class HomeController < ApplicationController
  def index
    if params[:q].present?
      @items = ThinkingSphinx.search("#{params[:q]}", :classes => [Item])
        .page(params[:page]).per(3)
    elsif params[:filter]
      _order_by, _scopes = []
      _items = Item.published
      _filter = params[:filter].select{|k,v| not v.include?("Any")}
      _filter.each do |k,v|
        case k
        when "viewed"
          if v.include?("More")
            _order_by.push("views_count DESC")
          elsif v.include?("Less")
            _order_by.push("views_count ASC")
          end
        when "date"
          if v.include?("Today")
            _scopes.push(:new_in_last_day)
          elsif v.include?("Week")
            _scopes.push(:new_in_last_week)
          elsif v.include?("Month")
            _scopes.push(:new_in_last_month)
          elsif v.include?("Year")
            _scopes.push(:new_in_last_year)
          end
        when "price"
          if v == "Free"
            _scopes.push(:free)
          elsif v == "Paid"
            _scopes.push(:paid)
          end
        end
      end
      @items = _items.where()
      .page(params[:page])
    else
      @items = Item.published.page(params[:page])
    end
  end

  def new_captcha
  end
end