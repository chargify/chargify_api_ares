Gem::Specification.new do |s|
  s.specification_version = 3 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.7'
  
  s.name    = 'chargify_api_ares'
  s.version = '0.5.2'
  s.date    = '2012-12-15'
  s.summary = 'A Chargify API wrapper for Ruby using ActiveResource'
  s.description = ''
  s.authors = ["Michael Klett", "Nathan Verni", "Rodrigo Franco", "Shay Frendt"]
  s.email = 'support@chargify.com'
  s.homepage = 'http://github.com/chargify/chargify_api_ares'
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = %w[lib]

  # Runtime Dependencies
  s.add_runtime_dependency('activeresource', '>= 2.3.5')

  # Development Dependencies
  s.add_development_dependency('rake', '~> 0.9.2')
  s.add_development_dependency('rspec', '~> 2.7.0')
  s.add_development_dependency('factory_girl', '~> 2.1.0')
  s.add_development_dependency('fakeweb', '~> 1.3.0')
  s.add_development_dependency('faker', '~> 1.0.1')
  s.add_development_dependency('guard-rspec', '~> 0.5.0')
  s.add_development_dependency('growl', '~> 1.0.3')
  s.add_development_dependency('rb-fsevent', '~> 0.4.2')
end
