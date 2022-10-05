source 'https://rubygems.org'

gemspec

group :development, :test do
  gem 'byebug'
end

if (version = ENV['ACTIVESUPPORT'])
  gem 'activesupport', "~> #{version}.0"
end

if (version = ENV['RACK'])
  gem 'rack', "~> #{version}.0"
end
