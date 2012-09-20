Orthodontic::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true
  # ----------------------------------------------------------
  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true
  # config.middleware.insert_before ActionDispatch::Static, Rack::SSL, :exclude => proc { |env| env['HTTPS'] != 'on' }
  # config.middleware.use Rack::SslEnforcer,
  #  :https_port => 55443,
  #  :http_port => 5580,
    # :redirect_to => 'https://89.209.76.243:55443',     # For when behind a proxy, like nginx
    #:only => [/^\/moderator/, /^\/account/],      # Force SSL on everything behind /moderator, ...
  #  :strict => true                                   # Force no-SSL for everything else

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    config.assets.precompile += %w(
      active_admin.css active_admin.js
      jquery-ui.css jquery-ui.js recorder.js
    )
  # Disable delivery errors, bad email addresses will be ignored
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 =>  587,
    :domain               => 'gmail.com',
    :user_name            => 'smogilevsky@provectus-it.com',
    :password             => 'slavaprovectus',
    :authentication       => 'plain',
    :enable_starttls_auto => true }

  # Mailer
  config.action_mailer.default_url_options = { :host => "50.19.75.77:80" }

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.after_initialize do
    ActiveMerchant::Billing::Base.mode = :test  #production
    ::GATEWAY = ActiveMerchant::Billing::PaypalGateway.new(
      :login => "seller_1332512555_biz_api1.gmail.com",
      :password => "1332512593",
      :signature => "Ai1PaghZh5FmBLCDCTQpwG8jB264APg.06Ef.OBMPXyJ4E-70ixY1phB"
    )
  end


  config.cache_classes = false
  config.whiny_nils = true
  # config.sass.cache = false
  # config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.assets.compress = false
  config.assets.debug = true
  config.assets.logger = false



end
