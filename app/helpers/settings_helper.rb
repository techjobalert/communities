module SettingsHelper
  # Func for get settings keyue by key

  def get_setting(key)
    val = Settings.find_by_key(key.to_sym).value
    if val.in?(["true", "false"])
      eval(val)
    elsif val.to_i
      val.to_i
    else
      val
    end
  end
end
