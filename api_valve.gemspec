$LOAD_PATH.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'api_valve'
  s.version     = ENV.fetch 'VERSION', '0.1.0'
  s.authors     = ['mkon']
  s.email       = ['konstantin@munteanu.de']
  s.homepage    = 'https://github.com/mkon/api_valve'
  s.summary     = 'Lightweight ruby/rack API reverse proxy or gateway'
  s.license     = 'MIT'

  s.files = Dir['lib/**/*', 'README.md']

  s.add_dependency 'activesupport', '>= 5.0.2', '< 6'
  s.add_dependency 'faraday', '~> 0.14'
  s.add_dependency 'multi_json', '~> 1.13'
  s.add_dependency 'rack', '~> 2'

  s.add_development_dependency 'rack-test', '~> 0'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rubocop', '0.56.0'
  s.add_development_dependency 'rubocop-rspec', '1.25.1'
  s.add_development_dependency 'simplecov', '~> 0'
  s.add_development_dependency 'timecop', '~> 0'
  s.add_development_dependency 'webmock', '~> 2'
end
