source 'http://rubygems.org'

gem 'foreman'
gem 'puma'
gem 'rack'
# Pin grape until this is fixed https://github.com/tim-vandecasteele/grape-swagger/issues/149
gem 'grape'
gem 'grape-swagger'
gem 'mongoid', github: 'mongoid/mongoid'
gem 'celluloid'
gem 'celluloid-io'
gem 'docker-api', :require => 'docker'
gem 'rake'

# Services
gem 'pg'

group :development do
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-puma'
  gem 'rb-inotify', :require => false
  gem 'pry'
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'fabrication'
  gem 'webmock'
  gem 'vcr'
  gem 'rubocop'
  gem 'codeclimate-test-reporter', require: nil
end
