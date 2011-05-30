# encoding: utf-8
require 'rubygems'
require 'bundler/setup'

require 'chargify_api_ares'

Spec::Runner.configure do |config|
  config.before(:all) do
    Chargify.configure do |c|
      c.subdomain = remote_configuration['subdomain']
      c.api_key = remote_configuration['api_key']
      if remote_configuration['site']
        c.site = remote_configuration['site']
      end
    end
  end
end

def run_remote_tests?
  remote_configuration['run_tests']
end

def remote_configuration
  @remote_configuration ||= load_remote_configuration_file
end

private

def load_remote_configuration_file
  configuration_file = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'remote.yml'))
  if File.exist?(configuration_file)
    YAML.load_file(configuration_file)
  else
    {}
  end
end