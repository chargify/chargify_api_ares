# encoding: utf-8
require 'rubygems'
require 'bundler/setup'

require 'chargify_api_ares'

require 'fakeweb'
require 'mocks/fake_resource'
ActiveResource::Base.send :include, ActiveResource::FakeResource
FakeWeb.allow_net_connect = false
require 'factory_girl'
require 'faker'
require 'factories'

Chargify.configure do |c|
  c.subdomain = 'test'
  c.api_key   = 'test'
end
 
RSpec.configure do |config|
  config.filter_run_excluding :remote => false
  
  config.after(:each) do
    ActiveResource::FakeResource.clean
  end
end

def test_domain
  "#{Chargify::Base.connection.site.scheme}://#{Chargify::Base.connection.user}:#{Chargify::Base.connection.password}@#{Chargify::Base.connection.site.host}:#{Chargify::Base.connection.site.port}"
end
