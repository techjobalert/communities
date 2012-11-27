class NotificationService
  def item_price_changed item
    begin
      Resque.enqueue(NotifyNow, id)
    rescue err
      Rails.logger.error err
    end
  end
end