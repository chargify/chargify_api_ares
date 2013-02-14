Gem::Specification.new do |s|
  s.specification_version = 3 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.7'
  
  s.name    = 'chargify_api_ares'
  s.version = '0.5.4'
  s.date    = '2013-02-14'
  s.summary = 'A Chargify API wrapper for Ruby using ActiveResource'
  s.description = ''
  s.authors = ["Michael Klett", "Nathan Verni", "Graham McIntire", "Rodrigo Franco", "Shay Frendt"]
  s.email = 'support@chargify.com'
  s.homepage = 'http://github.com/chargify/chargify_api_ares'
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = %w[lib]

  # Runtime Dependencies
  s.add_runtime_dependency('activeresource', '>= 2.3.5')

  # Development Dependencies
  s.add_development_dependency('rake', '~> 10.0.3')
  s.add_development_dependency('rspec', '~> 2.12.0')
  s.add_development_dependency('factory_girl', '~> 4.2.0')
  s.add_development_dependency('fakeweb', '~> 1.3.0')
  s.add_development_dependency('faker', '~> 1.1.2')
  s.add_development_dependency('guard-rspec', '~> 2.4.0')
  s.add_development_dependency('growl', '~> 1.0.3')
  s.add_development_dependency('rb-fsevent', '~> 0.9.2')
end
