source 'https://rubygems.org'

gem 'rails',                '3.2.11'

# Database Adapter
# Install instructions for Windows: http://blog.mmediasys.com/2011/07/07/installing-mysql-on-windows-7-x64-and-using-ruby-with-it/
# gem 'mysql2',               '0.3.11'
gem 'pg',                   '0.14.1'
gem 'thin',                 '~> 1.5.0',           :platforms => [ :mswin, :mingw ]
gem 'eventmachine',         '~> 1.0.0',           :platforms => [ :mswin, :mingw ]

# Gems used by project
gem 'contour',              '~> 1.1.3.pre2'
gem 'kaminari',             '~> 0.14.1'
gem 'carrierwave',          '~> 0.7.1'
gem 'audited-activerecord', '~> 3.0.0'
gem 'spreadsheet',          '~> 0.7.7'
gem 'systemu',              '~> 2.5.2'
gem 'rubyzip',              '~> 0.9.9'
gem 'mail_view',            '~> 1.0.3'
gem 'naturalsort',          '~> 1.1.1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',         '~> 3.2.6'
  gem 'coffee-rails',       '~> 3.2.2'
  gem 'uglifier',           '>= 1.0.3'
end

gem 'jquery-rails'

# Testing
group :test do
  # Pretty printed test output
  gem 'win32console',                             :platforms => [ :mswin, :mingw ]
  gem 'turn',               '~> 0.9.6'
  gem 'simplecov',          '~> 0.7.1',           :require => false
end
