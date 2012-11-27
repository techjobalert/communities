class ItemService 
  
  def change_price
    item = Item.find(item_id)
    
    item.change_price(price)
  end  

  def notification_service
    NotificationService.new
  end
end