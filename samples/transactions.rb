$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'chargify_api_ares'

# You could load your credentials from a file...
chargify_config = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'config', 'chargify.yml'))

Chargify.configure do |c|
  c.subdomain = chargify_config['subdomain']
  c.api_key   = chargify_config['api_key']
end


# Retrieve a list of all your customers
subscription = Chargify::Subscription.find(:all).first

transactions = subscription.transactions