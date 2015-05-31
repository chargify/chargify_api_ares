$:.unshift File.expand_path('../lib', File.dirname(__FILE__))

require 'bundler'
Bundler.require(:default, :development)

require 'support/fake_resource'
require 'pry'
require 'dotenv'

Dotenv.load

FactoryGirl.find_definitions
ActiveResource::Base.send :include, ActiveResource::FakeResource
FakeWeb.allow_net_connect = false

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = true
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :fakeweb
end

RSpec.configure do |config|
  config.filter_run :focused => true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.alias_example_to :fit, :focused => true
  config.color_enabled = true
  config.filter_run_excluding :remote => true

  config.include FactoryGirl::Syntax::Methods

  config.before(:each, :fake_resource) do
    ActiveResource::FakeResource.enable
  end

  config.after(:each, :fake_resource) do
    ActiveResource::FakeResource.disable
  end
end

def test_domain
  "#{Chargify::Base.connection.site.scheme}://#{Chargify::Base.connection.user}:#{Chargify::Base.connection.password}@#{Chargify::Base.connection.site.host}:#{Chargify::Base.connection.site.port}"
end
