$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'chargify_api_ares'

# You could load your credentials from a file...
chargify_config = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'config', 'chargify.yml'))

Chargify.configure do |c|
  c.subdomain = chargify_config['subdomain']
  c.api_key   = chargify_config['api_key']
  if chargify_config['site']
    c.site = chargify_config['site']
  end
end

#
# This assumes you have a product family with a metered component setup
#
product_family = Chargify::ProductFamily.find(:first)
component =  Chargify::Component.find(:first, :params => {:product_family_id => product_family.id})
subscription = Chargify::Subscription.find(:first)


u = Chargify::Usage.new
u.subscription_id = subscription.id
u.component_id = component.id
u.quantity = 5
d = DateTime.now.to_s
u.memo = d
puts d
u.save


x = Chargify::Usage.find(:last, :params => {:subscription_id => subscription.id, :component_id => component.id})
puts x.memo == d