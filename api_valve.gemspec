$LOAD_PATH.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'api_valve'
  s.version     = ENV.fetch 'VERSION', '1.2.0'
  s.authors     = ['mkon']
  s.email       = ['konstantin@munteanu.de']
  s.homepage    = 'https://github.com/mkon/api_valve'
  s.summary     = 'Lightweight ruby/rack API reverse proxy or gateway'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 3.0', '< 4'

  s.files = Dir['lib/**/*', 'README.md']

  s.add_dependency 'activesupport', '>= 6.1', '< 7.1'
  s.add_dependency 'faraday', '>= 0.14', '<= 2.7.11'
  s.add_dependency 'json', '>= 2.0'
  s.add_dependency 'rack', '>= 2', '< 4'

  s.add_development_dependency 'json_spec', '~> 1.1'
  s.add_development_dependency 'rack-test', '~> 2.0'
  s.add_development_dependency 'rackup'
  s.add_development_dependency 'rspec', '~> 3.7'
  s.add_development_dependency 'rubocop', '1.57.2'
  s.add_development_dependency 'rubocop-rspec', '2.25.0'
  s.add_development_dependency 'simplecov', '~> 0.16'
  s.add_development_dependency 'timecop', '~> 0.9'
  s.add_development_dependency 'webmock', '~> 3.4'

  s.metadata['rubygems_mfa_required'] = 'true'
end
