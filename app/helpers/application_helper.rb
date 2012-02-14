module ApplicationHelper
  def date_format(date) 
    date.strftime('%m/%d/%Y') if date.present?
  end  
end
