module PubUnpub

  def publish!
    self.published = true
    self.published_at = Time.now if self.has_attribute?(:published_at)
    self.save!
    if self.user.has_attribute?(_get_counter_name)
      self.user[_get_counter_name] +=1
      self.user.save!
    end
  end

  def unpublish!
    self.published = false
    self.unpublished_at = Time.now if self.has_attribute?(:unpublished_at)
    self.save!

    if self.user.has_attribute?(_get_counter_name)
      self.user[_get_counter_name] -=1
      self.user.save!
    end
  end

  protected

  def _get_counter_name
    :"#{self.class.name.downcase.pluralize}_count"
  end

end