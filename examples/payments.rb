$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require "chargify_api_ares"

Chargify.configure do |c|
  c.subdomain = ENV['CHARGIFY_SUBDOMAIN']
  c.api_key   = ENV['CHARGIFY_API_KEY']
end

# Find a Chargify Subscription
sub = Chargify::Subscription.find_by_customer_reference 'abc-123-def-456'

# Record an external payment on the Chargify Subscription
pmt = sub.payment(
  amount_in_cents: 2500,
  memo: "Pre-payment for..."
)

# Or, create the external payment directly:
pmt = Chargify::Payment.create(
  subscription_id: sub.id,
  amount_in_cents: 2500,
  memo: "Pre-payment for..."
)
