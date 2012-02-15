module SettingsHelper
  # Func for get settings value by key

  def get_setting(key)
    val = Settings.find_by_var(key.to_sym).value
    if val.in?(["true", "false"])
      eval(val)
    elsif val.to_i
      val.to_i
    else
      val
    end
  end

end
