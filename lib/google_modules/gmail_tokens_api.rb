module GmailTokensApi
  def refresh_gmail_token
    response = send_refresh_token_request
    token_attrs = ActiveSupport::JSON.decode(response)

    social_account_credential.update_attribute(
      :google_token, token_attrs['access_token']
    )
  end

  def refresh_token_params
    {
      client_id: GOOGLE_CLIENT_ID,
      client_secret: GOOGLE_CLIENT_SECRET,
      refresh_token: google_refresh_token,
      grant_type: 'refresh_token'
    }
  end

  def send_refresh_token_request
    RestClient.post(GOOGLE_REFRESH_TOKEN_URL, refresh_token_params).body
  end
end