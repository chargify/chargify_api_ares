# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "chargify_api_ares/version"

Gem::Specification.new do |s|
  s.name        = "chargify_api_ares"
  s.version     = ChargifyApiAres::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Michael Klett", "Nathan Verni", "The Lab Rats @ Phase Two Labs", "Brian Rose"]
  s.email       = ["mklett@grasshopper.com"]
  s.homepage    = "http://github.com/grasshopperlabs/chargify_api_ares"
  s.summary     = %q{A Chargify API wrapper for Ruby using ActiveResource}

  s.rubyforge_project = "chargify_api_ares"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "activeresource", ["~> 2.0"]

  s.add_development_dependency "rspec", ["2.5.0"]
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "faker"
end
