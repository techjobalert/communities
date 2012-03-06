class Item < ActiveRecord::Base
  #include PubUnpub
  include SettingsHelper
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :title, :description, :tag_list, :paid, :user, :user_id,
    :views_count, :amount, :price, :state
  validates :title, :description, :presence => true

  acts_as_commentable
	acts_as_taggable
  acts_as_followable

  # Scopes

  scope :state_is, lambda {|state| where(:state => state)}
  scope :published, where("state <> 'archived'").order("created_at DESC")
  scope :new_in_last_day, where(:created_at => (Date.today.to_time..Time.now))
  scope :new_in_last_week, where(:created_at => ((Time.now.weeks_ago 1)..Time.now))
  scope :new_in_last_month, where(:created_at => ((Time.now.months_ago 1)..Time.now))
  scope :new_in_last_year, where(:created_at => ((Time.now.years_ago 1)..Time.now))
  scope :paid, where("price != 0")
  scope :free, where(:price => 0 )

  # Handlers
  before_create  :add_to_contributors

  belongs_to  :user, :counter_cache => true, class_name: :User, inverse_of: :items
  # belongs_to  :creator, class_name: :User, inverse_of: :items

  has_many    :comments, :dependent => :destroy
  has_many    :contributions
  has_many    :contributors, through: :contributions

  fires :created_item,    :on     => :create,
                          :actor  => :user

  fires :updated_item,    :on     => :update,
                          :actor  => :user

  fires :destroyed_item,  :on     => :destroy,
                          :actor  => :user

  state_machine :state, :initial => :moderated do
    # after_transition :on => :publish do |item|
    #   if self.user.has_attribute?(_get_counter_name)
    #     self.user[_get_counter_name] +=1
    #     self.user.save!
    #   end
    # end

    event :moderate do
      transition [:denied, :published] => :moderated
    end

    event :publish do
      transition :moderated => :published
    end

    event :archive do
      transition all => :archived
    end

    event :deny do
      transition [:moderated, :published] => :denied
    end
  end

  paginates_per 3

  def add_to_contributors
    self.contributors << user
  end

  def self.paginate(options = {})
    page(options[:page]).per(options[:per_page])
  end
  # SEARCH
  def self.parse_params(params)
    options = {}
    if params[:date] and not params[:date].include?("Any")
      options[:date] = case params[:date]
      when "Today"
        Date.today.to_time
      when "1 Week"
        (Time.now.weeks_ago 1)
      when "1 Month"
        (Time.now.months_ago 1)
      when "1 Year"
        (Time.now.years_ago 1)
      else
        Time.zone.now
      end
      p options[:date]
    end

    if params[:views] and not params[:views].include?("Any")
      options[:views] = case params[:views]
      when "More Viewed"
        "desc"
      when "Less Viewed"
        "asc"
      end
    end

    # if params[:price] and not params[:price].include?("Free/Paid")
    #   value != "basic" ? scope.where(:user_id => controller.current_user.id) : scope
    options
  end
  def self.search(params)
    options = parse_params(params)
    per_page = params[:per_page]? params[:per_page] : 3
    tire.search(page: params[:page], per_page: per_page) do
      query do
        boolean do
          must { string "*"+params[:q]+"*", default_operator: "AND" } if params[:q].present?
          must { term  :state, "published"}
          if  params[:price] == "Paid"
            must_not { term :price, 0 }
          elsif params[:price] == "Free"
            must { term :price, 0 }
          end
          must { range :created_at, from: options[:date] ,to: Time.now}
          must { term :user_id, params[:current_user_id] } if params[:current_user_id].present?
        end
      end
      sort { by :views_count, options[:views] }

      # facet "authors" do
      #   terms :author_id
      # end
      # raise to_curl
    end
  end

end
