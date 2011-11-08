$:.unshift File.expand_path('../lib', File.dirname(__FILE__))

require 'chargify_api_ares'
require 'rspec'
require 'fakeweb'
require 'support/fake_resource'
require 'factory_girl'
require 'faker'
require 'factories'

ActiveResource::Base.send :include, ActiveResource::FakeResource
FakeWeb.allow_net_connect = false

Chargify.configure do |c|
  c.subdomain = 'test'
  c.api_key   = 'test'
end
 
RSpec.configure do |config|
  config.filter_run :focused => true
  config.run_all_when_everything_filtered = true
  config.alias_example_to :fit, :focused => true
  config.color_enabled = true
  
  config.after(:each) do
    ActiveResource::FakeResource.clean
  end
end

def test_domain
  "#{Chargify::Base.connection.site.scheme}://#{Chargify::Base.connection.user}:#{Chargify::Base.connection.password}@#{Chargify::Base.connection.site.host}:#{Chargify::Base.connection.site.port}"
end
