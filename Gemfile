source 'http://rubygems.org'

gem 'rails', '~>3.2.0'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.0'
  gem 'coffee-rails', '~> 3.2.0'
  gem 'uglifier', '>= 1.0.3'
end

# Use unicorn as the web server
gem 'unicorn'
gem 'mysql2'
gem 'jquery-rails'
gem 'haml-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

# Heroku
group :development, :test do
  gem 'rspec-rails'
  gem 'heroku'
  gem 'sqlite3'
  gem 'thin'
  gem 'turn', :require => false
end

group :production do  
end

# Permissions and Authorization
gem 'cancan'                                                      # Permissions
gem 'devise'
gem "galetahub-simple_captcha", :require => "simple_captcha"

# Validators
gem 'default_value_for'
gem 'date_validator'

#gem 'therubyracer'                                               # JS runtime
gem 'client_side_validations'                                     # clientside validation by ajax
gem 'kaminari'                                                    # Pagination
gem 'activeadmin'                                                 # ActiveAdmin administration

# Upload
gem 'carrierwave'                                                 # upload processor
gem 'carrierwave_backgrounder'                                    # upload processor(background-jobs)
gem 'mini_magick'                                                 # image processing

# full text search
gem 'thinking-sphinx', '2.0.10'                           		  # Sphinx support

gem 'whenever'                                                    # Writing and deploying cron jobs

gem 'ancestry'                                                    # nested obj, parents, childrens...
gem 'acts-as-taggable-on'                                         # tags

gem 'resque'

gem 'acts_as_commentable_with_threading', :git => "git://github.com/elight/acts_as_commentable_with_threading.git"
gem 'acts_as_follower'