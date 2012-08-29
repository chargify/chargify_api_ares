require 'spec_helper'

FakeWeb.allow_net_connect = true

unless File.exists?(File.join(File.dirname(__FILE__), 'remote.yml'))
  STDERR.puts "\nERROR: Make sure a remote.yml file exists at ./spec/remote/remote.yml\n\n"
  abort
end

RSpec.configure do |config|
  config.before(:all) do
    Chargify.configure do |c|
      c.api_key = remote_configuration['api_key']
      c.site = remote_configuration['site']
    end
  end
end

private

def remote_configuration
  @remote_configuration ||= YAML.load_file(File.expand_path(File.join(File.dirname(__FILE__), 'remote.yml')))
end
