# TODO: Fix remote specs
# require 'rubygems'
# require 'rspec'
# $LOAD_PATH.unshift(File.dirname(__FILE__))
# $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))

# require 'chargify_api_ares'

# RSpec.configure do |config|
#   config.before(:all) do
#     Chargify.configure do |c|
#       c.api_key = remote_configuration['api_key']
#       c.site = remote_configuration['site']
#     end
#   end
# end

# def run_remote_tests?
#   remote_configuration['run_tests'] === true
# end

# def remote_configuration
#   @remote_configuration ||= load_remote_configuration_file
# end

# private

# def load_remote_configuration_file
#   configuration_file = File.expand_path(File.join(File.dirname(__FILE__), 'remote.yml'))
#   if File.exist?(configuration_file)
#     YAML.load_file(configuration_file)
#   else
#     {}
#   end
# end
