Gem::Specification.new do |s|
  s.name = %q{chargify_api_ares}
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Klett", "Nathan Verni", "Rodrigo Franco"]
  s.date = %q{2011-03-02}
  s.description = %q{}
  s.email = %q{support@chargify.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
     "README.md"
  ]
  s.files = [
    ".gitignore",
     "LICENSE.txt",
     "README.md",
     "Rakefile",
     "VERSION",
     "chargify_api_ares.gemspec",
     "config/remote.example.yml",
     "lib/chargify_api_ares.rb",
     "samples/customers.rb",
     "samples/metered_components.rb",
     "samples/products.rb",
     "samples/subscriptions.rb",
     "samples/transactions.rb",
     "spec/base_spec.rb",
     "spec/components_spec.rb",
     "spec/customer_spec.rb",
     "spec/factories.rb",
     "spec/mocks/fake_resource.rb",
     "spec/product_spec.rb",
     "spec/remote/remote_spec.rb",
     "spec/remote/spec_helper.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/subscription_spec.rb",
     "spec/subscriptions_component_spec.rb"
  ]
  s.homepage = %q{http://github.com/grasshopperlabs/chargify_api_ares}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A Chargify API wrapper for Ruby using ActiveResource}
  s.test_files = [
    "spec/base_spec.rb",
     "spec/components_spec.rb",
     "spec/customer_spec.rb",
     "spec/factories.rb",
     "spec/mocks/fake_resource.rb",
     "spec/product_spec.rb",
     "spec/remote/remote_spec.rb",
     "spec/remote/spec_helper.rb",
     "spec/spec_helper.rb",
     "spec/subscription_spec.rb",
     "spec/subscriptions_component_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
