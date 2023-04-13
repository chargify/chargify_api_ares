require 'spec_helper'

unless File.exists?(File.join(File.dirname(__FILE__), 'remote.yml'))
  STDERR.puts "\nERROR: Make sure a remote.yml file exists at ./spec/remote/remote.yml\n\n"
  abort
end

RSpec.configure do |config|
  config.before(:all) do
    Chargify.configure do |c|
      c.api_key    = remote_configuration['api_key']
      c.protocol   = remote_configuration['protocol']  if remote_configuration['protocol']
      c.domain     = remote_configuration['domain']    if remote_configuration['domain']
      c.subdomain  = remote_configuration['subdomain'] if remote_configuration['subdomain']
      c.site       = remote_configuration['site']      if remote_configuration['site']
    end
  end
end

private

def remote_configuration
  @remote_configuration ||= YAML.load_file(File.expand_path(File.join(File.dirname(__FILE__), 'remote.yml')))
end
