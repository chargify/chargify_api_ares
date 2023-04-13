$:.unshift File.expand_path('../lib', File.dirname(__FILE__))

require 'bundler'
Bundler.require(:default, :development)

require 'support/fake_resource'
require 'pry'
require 'dotenv'
require 'webmock/rspec'

Dotenv.load

FactoryGirl.find_definitions
ActiveResource::Base.send :include, ActiveResource::FakeResource

WebMock.after_request do |request_signature, response|
  # puts request_signature.query
  puts "Request #{request_signature} was made and #{response.body} was returned"
end

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = true
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
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

  config.before(:each) do
    WebMock.enable!
    Chargify.configure {}
  end
end

def test_domain
  "#{Chargify::Base.connection.site.scheme}://#{Chargify::Base.connection.site.host}"
end
