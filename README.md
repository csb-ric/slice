# Slice

[![Build Status](https://travis-ci.org/remomueller/slice.svg?branch=master)](https://travis-ci.org/remomueller/slice)
[![Dependency Status](https://gemnasium.com/remomueller/slice.svg)](https://gemnasium.com/remomueller/slice)
[![Code Climate](https://codeclimate.com/github/remomueller/slice/badges/gpa.svg)](https://codeclimate.com/github/remomueller/slice)

A clinical research interface geared at collecting robust and consistent data by
providing a strong framework for designing data dictionaries and collection
forms. Slice also provides exports of the data and the data dictionaries created
as well as providing a simple reporting interface. Using Rails 5.0+ and
Ruby 2.4+.

## Installation

[Prerequisites Install Guide](https://github.com/remomueller/documentation):
Instructions for installing prerequisites like Ruby, Git, JavaScript compiler,
etc.

Once you have the prerequisites in place, you can proceed to install bundler
which will handle most of the remaining dependencies.

```
gem install bundler
```

This readme assumes the following installation directory: /var/www/slice

```
cd /var/www

git clone https://github.com/remomueller/slice.git

cd slice

bundle install
```

Install default configuration files for database connection, email server
connection, server url, and application name.

```
ruby lib/initial_setup.rb

bundle exec rake db:migrate RAILS_ENV=production

bundle exec rake assets:precompile RAILS_ENV=production
```

Run Rails Server (or use Apache or nginx)

```
rails s -p80
```

Open a browser and go to: [http://localhost](http://localhost)

All done!

## Setting up Daily Digest Emails, Password Reminders, and Refreshing Sitemap

Edit Cron Jobs `sudo crontab -e` to run the task `lib/tasks/daily_digest.rake`

```
SHELL=/bin/bash
0 1 * * * source /etc/profile.d/rvm.sh && cd /var/www/slice && /usr/local/rvm/gems/ruby-2.4.0/bin/bundle exec rake daily_digest RAILS_ENV=production
0 1 * * * source /etc/profile.d/rvm.sh && cd /var/www/slice && /usr/local/rvm/gems/ruby-2.4.0/bin/bundle exec rake passwords:expire RAILS_ENV=production
0 2 * * * source /etc/profile.d/rvm.sh && cd /var/www/slice && /usr/local/rvm/gems/ruby-2.4.0/bin/bundle exec rake sitemap:refresh RAILS_ENV=production
```

## Contributing to Slice

- Check out the latest master to make sure the feature hasn't been implemented
  or the bug hasn't been fixed yet
- Check out the issue tracker to make sure someone already hasn't requested it
  and/or contributed it
- Fork the project
- Start a feature/bugfix branch
- Commit and push until you are happy with your contribution
- Make sure to add tests for it. This is important so I don't break it in a
  future version unintentionally.
- Please try not to mess with the Rakefile, version, or history. If you want to
  have your own version, or is otherwise necessary, that is fine, but please
  isolate to its own commit so I can cherry-pick around it.

## License

Slice is released under the [MIT License](http://www.opensource.org/licenses/MIT).
