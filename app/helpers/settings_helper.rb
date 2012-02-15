module SettingsHelper
  # Func for get settings keyue by key

  def get_setting(key)
    key = Settings.find_by_key(key.to_sym).value
    if key.in?(["true", "false"])
      ekey(key)
    elsif key.to_i
      key.to_i
    else
      key
    end
  end

end
