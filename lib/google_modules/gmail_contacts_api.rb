module GmailContactsApi
  def gmail_contacts
    response = send_request

  	gmail_contacts = []
  	contacts = ActiveSupport::JSON.decode(response)

    contacts['feed']['entry'].each do |contact|
      google_name = contact['title']['$t']

      email_address = ''
      contact['gd$email'].to_a.each do |email|
        email_address = email['address']
      end

      photo_url = ''
      contact['link'].to_a.each do |photo|
        if photo['rel'].present? && photo['rel'].include?('rel#photo')
          photo_url = photo['href']
        end
      end

      contact_data = { name: google_name, email: email_address }
      contact_data[:photo_url] = photo_url + "?oauth_token=#{google_token}" if photo_url.present?

      gmail_contacts << contact_data
    end

    gmail_contacts
  end

  def send_request
  	RestClient.get("https://www.google.com/m8/feeds/contacts/default/full?oauth_token=" + google_token + "&max-results=50000&alt=json").body
  end
end