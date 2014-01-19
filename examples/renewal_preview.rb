$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'chargify_api_ares'

# You could load your credentials from a file...
chargify_config = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'chargify.yml'))

Chargify.configure do |c|
  c.subdomain = chargify_config['subdomain']
  c.api_key   = chargify_config['api_key']
end

# Fetch list of subscriptions
subscriptions = Chargify::Subscription.find(:all)

# Grab the first id
id = subscriptions.first.id


# Fetch a preview of the next renewal
preview = Chargify::Renewal::Preview.create(
  :subscription_id => id,
)

# The next assessment date
puts preview.next_assessment_at

# The existing balance
puts preview.existing_balance_in_cents

# The total charges for the next renwal
puts preview.total_in_cents

# The total total amount due (existing balance + total)
puts preview.total_amount_due_in_cents

