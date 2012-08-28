require 'rubygems'
require 'rspec'
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))

require 'chargify_api_ares'

unless File.exists?(File.join(File.dirname(__FILE__), 'remote.yml'))
  STDERR.puts "\nERROR: Make sure a remote.yml file exists at ./spec/remote/remote.yml\n\n"
  abort
end

RSpec.configure do |config|
  config.filter_run :focused => true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.alias_example_to :fit, :focused => true
  config.color_enabled = true
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
