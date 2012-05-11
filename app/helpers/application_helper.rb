module ApplicationHelper
  def date_format(date)
    date.strftime('%m/%d/%Y') if date.present?
  end

  def text_with_br text
    raw text.strip().gsub(" ","<br>")
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder, :removable => true)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def secure_link(attachment, url)

    if attachment.present?
      item = attachment.item
      path = File.basename(url)

      if current_user and item
        if (item.paid? and item.purchased?(current_user)) or (!item.paid?) or item.user == current_user or current_user.admin?

          salt = "oth360"
          expiration_time = (Time.now + 30.seconds).to_i
          str = "#{salt}#{expiration_time}"
          md5 = Base64.encode64(Digest::MD5.digest(str))
          secret_string = md5.tr("+/", "-_").sub('==', '').chomp

          "/files/#{secret_string}/#{expiration_time}/#{attachment.id}/#{path}"
        end
      end
    end
  end

end
